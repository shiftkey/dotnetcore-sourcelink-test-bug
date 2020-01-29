dotnet tool restore
dotnet build -c Release
dotnet sourcelink test bin/Release/netstandard2.0/dotnetcore-sourcelink-test-bug.dll
