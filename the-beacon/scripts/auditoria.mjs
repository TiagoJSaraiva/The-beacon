// Prepara a auditoria de comentários, duplicação e código morto por fluxo (decisão 0032). Não
// julga nada: monta o mapa fluxo -> scripts a partir das notas de docs/sistemas/, o índice de
// todas as funções do jogo e os candidatos a código morto, para os revisores do passo de
// auditoria de .agents/fluxos/revisar.md lerem.
//
// Uso: node scripts/auditoria.mjs                         fluxos tocados pelo diff
//      node scripts/auditoria.mjs --tudo                  todos os fluxos
//      node scripts/auditoria.mjs --fluxo pesca,combate   fluxos escolhidos
// Saída em .auditoria/ (ignorada pelo git): indice.md e fluxos/<fluxo>.md.
import { spawnSync } from "node:child_process";
import { existsSync, mkdirSync, readdirSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { dirname, join, relative, resolve, sep } from "node:path";
import { fileURLToPath } from "node:url";

/** Pasta do projeto Godot (a que tem project.godot). */
const root = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const OUT_DIR = ".auditoria";
const SYSTEMS_DIR = "docs/sistemas";
const ORPHANS = "sem-sistema";
// Scripts sem nota por grupo do --tudo, para nenhum revisor receber o jogo inteiro.
const ORPHAN_GROUP_SIZE = 12;
const FUNC_PATTERN = /^(\s*)(?:static\s+)?func\s+(\w+)/;
const DOC_PATTERN = /^\s*##/;
const CITED_PATTERN = /`(?:res:\/\/)?([^`\s]+\.(?:gd|tscn|tres))`/g;
const NAME_PATTERN = /[A-Za-z_]\w*/g;
// Chamadas pelo motor, nunca pelo código do jogo: não contam como candidatas a código morto.
const ENGINE_CALLBACKS = new Set([
    "_init", "_static_init", "_ready", "_enter_tree", "_exit_tree", "_process", "_physics_process",
    "_input", "_unhandled_input", "_unhandled_key_input", "_shortcut_input", "_gui_input",
    "_notification", "_draw", "_to_string", "_get", "_set", "_get_property_list",
    "_validate_property", "_property_can_revert", "_property_get_revert",
    "_get_configuration_warnings", "_integrate_forces", "_can_drop_data", "_drop_data",
    "_get_drag_data", "_make_custom_tooltip", "_has_point", "_get_minimum_size", "_run",
    "_iter_init", "_iter_next", "_iter_get",
]);

/** Lê um arquivo de texto como linhas, sem BOM e aceitando LF ou CRLF. */
function readLines(path) {
    const text = readFileSync(path, "utf8").replace(/^﻿/, "");
    const lines = text.split(/\r?\n/);
    // Um arquivo terminado em quebra de linha não tem uma última linha vazia de verdade.
    if (lines.length > 0 && lines.at(-1) === "") {
        lines.pop();
    }
    return lines;
}

/** Caminho relativo à raiz, sempre com "/" (o mesmo formato do git e do res://). */
function toProjectPath(absolutePath, base = root) {
    return relative(base, absolutePath).split(sep).join("/");
}

/**
 * Executa um programa e devolve { status, output }. `shell` só é preciso no Windows para
 * .cmd (ex.: npx), que o Node não executa diretamente.
 */
function run(command, args, options = {}) {
    const result = spawnSync(command, args, {
        cwd: options.cwd ?? root,
        encoding: "utf8",
        env: options.env ?? process.env,
        shell: options.shell ?? false,
        stdio: options.inherit ? "inherit" : "pipe",
        maxBuffer: 64 * 1024 * 1024,
    });
    if (result.error) {
        return { status: null, output: "", error: result.error };
    }
    const output = options.inherit ? "" : `${result.stdout ?? ""}${result.stderr ?? ""}`;
    return { status: result.status, output };
}

function fail(message) {
    console.log(`ERRO: ${message}`);
    process.exit(1);
}

/** Arquivos com uma das extensões, relativos à raiz, sem addons/ nem pastas ocultas. */
function listFiles(extensions) {
    const result = [];
    const walk = (dir) => {
        for (const entry of readdirSync(dir, { withFileTypes: true })) {
            if (entry.name.startsWith(".")) {
                continue;
            }
            const full = join(dir, entry.name);
            if (entry.isDirectory()) {
                if (entry.name !== "addons") {
                    walk(full);
                }
            } else if (extensions.some((ext) => entry.name.endsWith(ext))) {
                result.push(toProjectPath(full));
            }
        }
    };
    walk(root);
    return result.sort();
}

/** A linha sem o comentário `#`, mantendo strings (call("nome") é uma referência). */
function codeOf(line) {
    let quote = null;
    for (let i = 0; i < line.length; i++) {
        const char = line[i];
        if (quote) {
            if (char === "\\") {
                i++;
            } else if (char === quote) {
                quote = null;
            }
        } else if (char === '"' || char === "'") {
            quote = char;
        } else if (char === "#") {
            return line.slice(0, i);
        }
    }
    return line;
}

const indentOf = (line) => line.length - line.trimStart().length;

/** Funções de um script: nome, linha, assinatura e o ## em uma linha. */
function functionsOf(path) {
    const lines = readLines(join(root, path));
    const result = [];
    lines.forEach((line, i) => {
        const match = line.match(FUNC_PATTERN);
        if (!match) {
            return;
        }
        const signature = [line.trim()];
        for (let j = i + 1; j < lines.length && !signature.at(-1).endsWith(":"); j++) {
            signature.push(lines[j].trim());
        }
        let docStart = i;
        while (docStart > 0 && DOC_PATTERN.test(lines[docStart - 1]) && indentOf(lines[docStart - 1]) === indentOf(line)) {
            docStart--;
        }
        const doc = lines
            .slice(docStart, i)
            .map((docLine) => docLine.trim().replace(/^##\s?/, ""))
            .join(" ")
            .trim();
        result.push({
            path,
            name: match[2],
            line: i + 1,
            signature: signature.join(" ").replace(/:$/, ""),
            doc: doc.length > 200 ? `${doc.slice(0, 197)}...` : doc,
        });
    });
    return result;
}

/** Onde cada nome aparece fora da própria definição: nome -> lista de arquivos (com repetição). */
function referencesOf(names, files) {
    const refs = new Map([...names].map((name) => [name, []]));
    for (const path of files) {
        const isScript = path.endsWith(".gd");
        for (const raw of readLines(join(root, path))) {
            let code = isScript ? codeOf(raw) : raw;
            // A definição não é uma referência a si mesma.
            code = code.replace(FUNC_PATTERN, "$1");
            for (const token of code.match(NAME_PATTERN) ?? []) {
                refs.get(token)?.push(path);
            }
        }
    }
    return refs;
}

/** Expande `pasta/{a,b}.tres` em `pasta/a.tres` e `pasta/b.tres`. */
function expandBraces(token) {
    const match = token.match(/^(.*)\{([^}]+)\}(.*)$/);
    if (!match) {
        return [token];
    }
    return match[2].split(",").map((part) => `${match[1]}${part.trim()}${match[3]}`);
}

/** Scripts ligados a uma cena ou recurso por ext_resource. */
function scriptsOfResource(path) {
    const result = [];
    for (const line of readLines(join(root, path))) {
        if (line.startsWith("[ext_resource") && line.includes('type="Script"')) {
            const match = line.match(/path="res:\/\/([^"]+\.gd)"/);
            if (match) {
                result.push(match[1]);
            }
        }
    }
    return result;
}

/**
 * Lê as notas de sistema. Cada nota é um fluxo; seus membros são os arquivos citados entre
 * crases (caminho completo ou só o final, ex.: `bobber.gd`) e os scripts das cenas citadas.
 */
function readSystems(allFiles) {
    const systems = new Map();
    const broken = [];
    const dir = join(root, SYSTEMS_DIR);
    if (!existsSync(dir)) {
        return { systems, broken };
    }
    for (const entry of readdirSync(dir).sort()) {
        if (!entry.endsWith(".md") || entry === "README.md") {
            continue;
        }
        const note = `${SYSTEMS_DIR}/${entry}`;
        const members = new Set();
        const text = readLines(join(root, note)).join("\n");
        for (const match of text.matchAll(CITED_PATTERN)) {
            for (const token of expandBraces(match[1])) {
                // Padrões como `<inimigo>.tres`, `*_animations.tres` ou `level_0N.tscn` descrevem
                // uma família de arquivos; os nomes reais são sempre snake_case minúsculo.
                if (/[<>*]/.test(token) || /[A-Z]/.test(token.split("/").at(-1))) {
                    continue;
                }
                const found = allFiles.includes(token) ? [token] : allFiles.filter((file) => file.endsWith(`/${token}`));
                if (found.length === 0) {
                    broken.push({ note, token });
                }
                found.forEach((file) => members.add(file));
            }
        }
        for (const file of [...members]) {
            if (!file.endsWith(".gd")) {
                scriptsOfResource(file).forEach((script) => members.add(script));
            }
        }
        systems.set(entry.replace(/\.md$/, ""), { note, members });
    }
    return { systems, broken };
}

/** Arquivos tocados pelo diff: mudanças locais, arquivos novos e commits ainda não enviados. */
function changedFiles() {
    const commands = [
        ["-c", "core.quotepath=off", "diff", "--name-only", "--relative", "HEAD"],
        ["-c", "core.quotepath=off", "ls-files", "--others", "--exclude-standard"],
    ];
    // Colaborador compara com a main original; dono, com a própria main no remoto.
    for (const base of ["upstream/main", "origin/main"]) {
        if (run("git", ["rev-parse", "--verify", "--quiet", base], { cwd: root }).status === 0) {
            commands.push(["-c", "core.quotepath=off", "diff", "--name-only", "--relative", `${base}...HEAD`]);
            break;
        }
    }
    const result = new Set();
    for (const args of commands) {
        const { status, output } = run("git", args, { cwd: root });
        if (status !== 0) {
            continue;
        }
        output
            .split(/\r?\n/)
            .map((path) => path.trim())
            .filter((path) => path !== "")
            .forEach((path) => result.add(path));
    }
    return result;
}

// ---- Argumentos

const args = process.argv.slice(2);
let mode = "diff";
let requested = [];
for (let i = 0; i < args.length; i++) {
    if (args[i] === "--tudo") {
        mode = "tudo";
    } else if (args[i] === "--fluxo" && i + 1 < args.length) {
        mode = "fluxo";
        requested = args[++i].split(",").map((name) => name.trim()).filter((name) => name !== "");
    } else {
        fail(`argumento desconhecido: ${args[i]}`);
    }
}

// ---- Mapa, índice e referências

const allFiles = listFiles([".gd", ".tscn", ".tres"]);
// scripts/ guarda as ferramentas do projeto (parse_check.gd), não código do jogo.
const gameScripts = allFiles.filter((file) => file.endsWith(".gd") && !file.startsWith("test/") && !file.startsWith("scripts/"));
const { systems, broken } = readSystems(allFiles);
for (const system of systems.values()) {
    system.scripts = [...system.members].filter((file) => file.endsWith(".gd") && !file.startsWith("test/")).sort();
}
const flowsOfScript = new Map(gameScripts.map((script) => [script, []]));
for (const [name, system] of systems) {
    system.scripts.forEach((script) => flowsOfScript.get(script)?.push(name));
}
const orphans = gameScripts.filter((script) => flowsOfScript.get(script).length === 0);

const functions = gameScripts.flatMap(functionsOf);
const refs = referencesOf(new Set(functions.map((fn) => fn.name)), allFiles);
const deadCandidates = new Map();
for (const fn of functions) {
    if (ENGINE_CALLBACKS.has(fn.name)) {
        continue;
    }
    const where = refs.get(fn.name);
    const outsideTests = where.filter((file) => !file.startsWith("test/"));
    let reason = null;
    if (where.length === 0) {
        reason = "nenhuma referência fora da definição";
    } else if (outsideTests.length === 0) {
        reason = `referenciada só em testes (${[...new Set(where)].join(", ")})`;
    }
    if (reason) {
        deadCandidates.set(`${fn.path}::${fn.name}`, { ...fn, reason });
    }
}

// ---- Fluxos escolhidos

const selected = new Map();
const addOrphanGroups = (scripts) => {
    if (scripts.length === 0) {
        return;
    }
    // Grupos do mesmo tamanho: 15 scripts viram 8 + 7, não 12 + 3.
    const groups = Math.ceil(scripts.length / ORPHAN_GROUP_SIZE);
    const size = Math.ceil(scripts.length / groups);
    for (let g = 0; g < groups; g++) {
        const name = groups === 1 ? ORPHANS : `${ORPHANS}-${g + 1}`;
        selected.set(name, { note: null, scripts: scripts.slice(g * size, (g + 1) * size) });
    }
};
if (mode === "tudo") {
    systems.forEach((system, name) => selected.set(name, system));
    addOrphanGroups(orphans);
} else if (mode === "fluxo") {
    for (const name of requested) {
        if (!systems.has(name)) {
            fail(`fluxo desconhecido: ${name}. Fluxos: ${[...systems.keys()].join(", ")}`);
        }
        selected.set(name, systems.get(name));
    }
} else {
    const changed = changedFiles();
    for (const [name, system] of systems) {
        const touched = changed.has(system.note) || [...system.members].some((file) => changed.has(file));
        if (touched) {
            selected.set(name, system);
        }
    }
    addOrphanGroups(orphans.filter((script) => changed.has(script)));
}

// ---- Saída

rmSync(join(root, OUT_DIR), { recursive: true, force: true });
mkdirSync(join(root, OUT_DIR, "fluxos"), { recursive: true });

const index = [
    "# Índice de funções",
    "",
    "Todas as funções do jogo (fora de `test/` e `addons/`): linha, assinatura e o `##` em uma linha.",
    "Gerado por `node scripts/auditoria.mjs`; não edite.",
];
// Map.groupBy só existe a partir do Node 21; o projeto aceita 18.
const byScript = new Map();
for (const fn of functions) {
    if (!byScript.has(fn.path)) {
        byScript.set(fn.path, []);
    }
    byScript.get(fn.path).push(fn);
}
for (const script of gameScripts) {
    const flows = flowsOfScript.get(script);
    index.push("", `## ${script} (fluxos: ${flows.length > 0 ? flows.join(", ") : ORPHANS})`);
    for (const fn of byScript.get(script) ?? []) {
        index.push(`- ${fn.line} \`${fn.signature}\` — ${fn.doc || "(sem ##)"}`);
    }
}
writeFileSync(join(root, OUT_DIR, "indice.md"), `${index.join("\n")}\n`, "utf8");

const summary = [];
for (const [name, flow] of selected) {
    const scripts = flow.scripts;
    const dead = [...deadCandidates.values()].filter((fn) => scripts.includes(fn.path));
    const file = `${OUT_DIR}/fluxos/${name}.md`;
    const text = [
        `# Fluxo: ${name}`,
        "",
        `- Nota do sistema: ${flow.note ? `\`${flow.note}\`` : "nenhuma (scripts que nenhuma nota de `docs/sistemas/` cita)"}`,
        `- Índice de todas as funções do jogo: \`${OUT_DIR}/indice.md\``,
        "",
        "## Scripts",
        ...(scripts.length > 0
            ? scripts.map((script) => `- \`${script}\` (${readLines(join(root, script)).length} linhas, ${(byScript.get(script) ?? []).length} funções)`)
            : ["- Nenhum script citado pela nota."]),
        "",
        "## Candidatos a código morto",
        "Contagem por nome em `.gd`, `.tscn` e `.tres`, fora de comentários; confirme antes de reportar.",
        ...(dead.length > 0 ? dead.map((fn) => `- \`${fn.path}:${fn.line}\` \`${fn.name}\`: ${fn.reason}`) : ["- Nenhum."]),
    ];
    writeFileSync(join(root, file), `${text.join("\n")}\n`, "utf8");
    summary.push(`  ${name}: ${file} (${scripts.length} scripts, ${dead.length} candidatos a código morto)`);
}

if (selected.size === 0) {
    console.log(mode === "diff" ? "Nenhum fluxo tocado pelo diff." : "Nenhum fluxo a revisar.");
} else {
    const label = { diff: "tocados pelo diff", tudo: "todos", fluxo: "escolhidos" }[mode];
    console.log(`Fluxos a revisar (${label}, ${selected.size}):`);
    summary.forEach((line) => console.log(line));
}
// Fora do --tudo, só o que diz respeito aos fluxos escolhidos (os scripts sem nota tocados pelo
// diff já estão no grupo sem-sistema).
const reportedOrphans = mode === "tudo" ? orphans : [];
const selectedNotes = new Set([...selected.values()].map((flow) => flow.note));
const reportedBroken = broken.filter((item) => selectedNotes.has(item.note));
if (reportedOrphans.length > 0) {
    console.log(`Scripts que nenhuma nota de ${SYSTEMS_DIR}/ cita (${reportedOrphans.length}):`);
    reportedOrphans.forEach((script) => console.log(`  ${script}`));
}
if (reportedBroken.length > 0) {
    console.log(`Arquivos citados nas notas que não existem (${reportedBroken.length}):`);
    reportedBroken.forEach((item) => console.log(`  ${item.note}: \`${item.token}\``));
}
console.log(`Índice: ${OUT_DIR}/indice.md (${functions.length} funções em ${gameScripts.length} scripts).`);
