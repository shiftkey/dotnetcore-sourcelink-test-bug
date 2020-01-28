dotnet tool restore
dotnet pack -c Release
dotnet sourcelink test bin/Release/dotnetcore-sourcelink-test-bug.1.0.0.nupkg
