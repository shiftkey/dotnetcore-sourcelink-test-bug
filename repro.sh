echo "Restore global tools"
dotnet tool restore

echo "Build project"
dotnet build -c Release

echo "Create package"
dotnet pack -c Release

echo "Test package"
dotnet sourcelink test bin/Release/dotnetcore-sourcelink-test-bug.1.0.0.nupkg
