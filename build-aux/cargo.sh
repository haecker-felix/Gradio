#!/bin/sh

if [[ $DEBUG = true ]]
then
    echo "DEBUG MODE"
    cargo build && cp $1/target/debug/gradio $2
else
    echo "RELEASE MODE"
    cargo build --release && cp $1/target/release/gradio $2
fi