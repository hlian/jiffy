#!/bin/sh

pushd Jiffy
xcrun swift -i Types.swift -i Combinators.swift -i DSON.swift -sdk $(xcrun --show-sdk-path --sdk macosx)
popd
