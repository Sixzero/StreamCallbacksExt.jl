@testset "RunInfo timing utilities" begin
    info = RunInfo(
        creation_time = 100.0,
        inference_start = 101.0,
        last_message_time = 102.0
    )

    @test get_total_elapsed(info) ≈ 2.0
    @test get_inference_elapsed(info) ≈ 1.0

    # Test with missing timestamps
    empty_info = RunInfo(creation_time = 100.0)
    @test isnothing(get_total_elapsed(empty_info))
    @test isnothing(get_inference_elapsed(empty_info))
end
