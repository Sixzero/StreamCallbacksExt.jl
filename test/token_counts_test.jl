@testset "TokenCounts" begin
    t1 = TokenCounts(input=1, output=2)
    t2 = TokenCounts(input=2, cache_read=1)
    t3 = t1 + t2
    @test t3.input == 3
    @test t3.output == 2
    @test t3.cache_read == 1
    @test t3.cache_write == 0
end
