# .NET Core 3 and SourceLink are now broken (gasp!)

This repository contains the steps and script to reproduce a weird problem I
encountered while using `sourcelink` to test .NET assemblies generated by .NET
Core 3. Bear with me, this is obscure and I'm still wrapping my head around
what's changed to introduce this bug.

To see this bug, you need to install .NET Core SDK `3.1.101`. I use
`global.json` with each step to ensure we're testing the right behaviour, so
you might need to install different SDKs yourself to see the same thing.

## What happened?

With that installed, run the `repro.sh` script at the root of the repository.

You'll see this output:

```
$ ./repro.sh
Tool 'sourcelink' (version '3.1.1') was restored. Available commands: sourcelink

Restore was successful.
Microsoft (R) Build Engine version 16.4.0+e901037fe for .NET Core
Copyright (C) Microsoft Corporation. All rights reserved.

  Restore completed in 27.55 ms for /home/shiftkey/src/dotnetcore-sourcelink-test-bug/dotnetcore-sourcelink-test-bug.csproj.
  dotnetcore-sourcelink-test-bug -> /home/shiftkey/src/dotnetcore-sourcelink-test-bug/bin/Release/netstandard2.0/dotnetcore-sourcelink-test-bug.dll

Build succeeded.
    0 Warning(s)
    0 Error(s)

Time Elapsed 00:00:00.73
1 Documents without URLs:
cc2dfcd56f5a115cc05c27d10c7c4b1545b3232fbbd18c0064fea0c99a24091f sha256 csharp /tmp/.NETStandard,Version=v2.0.AssemblyAttributes.cs
1 Documents with errors:
16b05566980c715287c2d8427a4627e52b0979f43211a8d3d4ae7d90c9b54555 sha256 csharp /home/shiftkey/src/dotnetcore-sourcelink-test-bug/obj/Release/netstandard2.0/dotnetcore-sourcelink-test-bug.AssemblyInfo.cs
https://raw.githubusercontent.com/shiftkey/dotnetcore-sourcelink-test-bug/e707de6428305d6a2bd997a516b5444592421cfd/obj/Release/netstandard2.0/dotnetcore-sourcelink-test-bug.AssemblyInfo.cs
error: url failed NotFound: Not Found
sourcelink test failed
```

The last part is the relevant bug report, and this seems to be a combination of:

 - .NET Core 3.x
 - class library targeting multiple platforms
 - generated file with assembly info

## What should happen?

To see what should happen, switch to the `netcore21` branch. I tested this
against .NET Core `2.1.803`:

```
$ ./repro.sh
Microsoft (R) Build Engine version 16.2.37902+b5aaefc9f for .NET Core
Copyright (C) Microsoft Corporation. All rights reserved.

  Restore completed in 117.76 ms for /Users/shiftkey/src/dotnetcore-sourcelink-test-bug/dotnetcore-sourcelink-test-bug.csproj.
  dotnetcore-sourcelink-test-bug -> /Users/shiftkey/src/dotnetcore-sourcelink-test-bug/bin/Release/netstandard2.0/dotnetcore-sourcelink-test-bug.dll
  Successfully created package '/Users/shiftkey/src/dotnetcore-sourcelink-test-bug/bin/Release/dotnetcore-sourcelink-test-bug.1.0.0.nupkg'.
sourcelink test passed: lib/netstandard2.0/dotnetcore-sourcelink-test-bug.dll
```

## But what is happening?

Why does this file now break SourceLink? That's what I'm trying to figure out
next. Looking at the file itself, it's a generated file that isn't meant to be
in version control anyway:

```c#
$ cat ./obj/Release/netstandard2.0/dotnetcore-sourcelink-test-bug.AssemblyInfo.cs
//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated by a tool.
//
//     Changes to this file may cause incorrect behavior and will be lost if
//     the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

using System;
using System.Reflection;

[assembly: System.Reflection.AssemblyCompanyAttribute("dotnetcore-sourcelink-test-bug")]
[assembly: System.Reflection.AssemblyConfigurationAttribute("Release")]
[assembly: System.Reflection.AssemblyFileVersionAttribute("1.0.0.0")]
[assembly: System.Reflection.AssemblyInformationalVersionAttribute("1.0.0+307b2b4e179373c0220095cff628b20c26540496")]
[assembly: System.Reflection.AssemblyProductAttribute("dotnetcore-sourcelink-test-bug")]
[assembly: System.Reflection.AssemblyTitleAttribute("dotnetcore-sourcelink-test-bug")]
[assembly: System.Reflection.AssemblyVersionAttribute("1.0.0.0")]

// Generated by the MSBuild WriteCodeFragment class.
```

What I need to understand:

 - when this was introduced - `3.0.x` or `3.1.x`?
 - why generated files are being looked at by sourcelink?
 - what needs to be done to fix the bug?
