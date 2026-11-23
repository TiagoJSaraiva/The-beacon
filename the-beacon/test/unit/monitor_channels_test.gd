extends GdUnitTestSuite


func test_starts_on_the_first_channel() -> void:
	var channels := MonitorChannels.new(3)
	assert_int(channels.current).is_equal(0)


func test_next_goes_through_every_channel_and_wraps_around() -> void:
	var channels := MonitorChannels.new(3)
	assert_int(channels.next()).is_equal(1)
	assert_int(channels.next()).is_equal(2)
	assert_int(channels.next()).is_equal(0)
	assert_int(channels.current).is_equal(0)


func test_without_channels_stays_on_zero() -> void:
	var channels := MonitorChannels.new(0)
	assert_int(channels.next()).is_equal(0)


func test_live_channel_is_the_open_one_while_the_screen_is_in_view() -> void:
	var channels := MonitorChannels.new(3)
	channels.on_screen = true
	channels.viewer_present = true
	assert_int(channels.live_channel()).is_equal(0)
	channels.next()
	assert_int(channels.live_channel()).is_equal(1)


func test_no_live_channel_with_the_screen_out_of_view() -> void:
	var channels := MonitorChannels.new(3)
	channels.next()
	channels.on_screen = false
	channels.viewer_present = true
	assert_int(channels.live_channel()).is_equal(MonitorChannels.NO_CHANNEL)


func test_no_live_channel_with_the_viewer_out_of_the_room() -> void:
	var channels := MonitorChannels.new(3)
	channels.on_screen = true
	channels.viewer_present = false
	assert_int(channels.live_channel()).is_equal(MonitorChannels.NO_CHANNEL)


func test_no_live_channel_without_channels() -> void:
	var channels := MonitorChannels.new(0)
	channels.on_screen = true
	channels.viewer_present = true
	assert_int(channels.live_channel()).is_equal(MonitorChannels.NO_CHANNEL)
