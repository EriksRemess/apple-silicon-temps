# apple-silicon-temps

Simple CLI app to print out Apple Silicon temperature sensor info.

`osx-cpu-temp` is drop-in replacement for lavoiesl/osx-cpu-temp to use with bpytop. List of required sensors gathered from Sensei app.

`temps` prints out all tempterature sensor info.

To recompile:

`gcc temps.m -o temps -framework IOKit -framework Foundation`

`gcc osx-cpu-temp.m -o osx-cpu-temp -framework IOKit -framework Foundation`



Based on:
* [freedomtan/sensors](https://github.com/freedomtan/sensors)
* [fermion-star/apple_sensors](https://github.com/fermion-star/apple_sensors)
