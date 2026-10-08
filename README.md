# adda-cplex
binary integer programs for the ADDA algorithm

## instructions

everything should be set up to reproduce the reported results. the coefficients in the misnamed [`test.dat`](./test.dat) are taken from the [ADDA](https://github.com/const-sambird/adda) algorithm, where the postgres cost estimator was invoked on a 10GB TPC-H database from 1100 queries (50 per template). The costs/benefits/budget are scaled down by a constant factor. again, you shouldn't need to touch them! unless you are running a different problem. you could run ADDA on any problem you like and input the data into here. but that is not what we did. we just did a TPC-H problem instance. anyway,

some things you might need to change:
* set REPLICAS in `test.dat` to the number of replicas in your DDBMS cluster (default is 4. minimum is 1. in principle there is no maximum!)
* set `cplex.tilim` at the very top of [`bip_maxcost.mod`](./bip_maxcost.mod) to whatever you'd like. it's in seconds. right now it's set to one hour. or remove it entirely to run to optimality, but we couldn't get there even after 12 hours on a pretty big machine

then you can run it, either in OPLIDE or from the command line:

```bash
/path/to/your/install/of/opl/bin/[platform]/oplrun bip_maxcost.mod test.dat
```
