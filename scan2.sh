#!/bin/bash
for puerto in `seq 1 65535`; do echo $puerto; scanpuerto $puerto; done
