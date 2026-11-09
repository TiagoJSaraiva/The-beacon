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
