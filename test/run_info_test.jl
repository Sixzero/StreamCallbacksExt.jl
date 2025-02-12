using StreamCallbacksExt: needs_tool_execution, RunInfo
using Test

@testset "RunInfo" begin
    info = RunInfo()
    @test !needs_tool_execution(info)
    
    info.stop_sequence = "STOP"
    @test needs_tool_execution(info)
    
    info.stop_sequence = "stop"
    @test needs_tool_execution(info)
    
    info.stop_sequence = nothing 
    @test !needs_tool_execution(info)
end
