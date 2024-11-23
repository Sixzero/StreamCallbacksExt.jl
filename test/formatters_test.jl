@testset "Formatters" begin
    tokens = TokenCounts(input=10, output=20, cache_read=5, cache_write=2)
    
    @testset "default_token_formatter" begin
        s = default_token_formatter(tokens, 0.5, 1.0)
        @test contains(s, "in=10")
        @test contains(s, "out=20")
        @test contains(s, "cache_read=5")
        @test contains(s, "\$0.5")
        @test contains(s, "1.0s")
    end

    @testset "compact_token_formatter" begin
        s = compact_token_formatter(tokens, 0.5, 1.0)
        @test contains(s, "in:10")
        @test contains(s, "out:20")
        @test contains(s, "w:2,r:5")
        @test contains(s, "\$0.5")
        @test contains(s, "1.0s")
    end
end
