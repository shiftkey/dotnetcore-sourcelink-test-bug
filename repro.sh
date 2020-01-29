git clean -xdf tools
dotnet tool install sourcelink --tool-path=tools
dotnet build -c Release
./tools/sourcelink test bin/Release/netstandard2.0/dotnetcore-sourcelink-test-bug.dll
