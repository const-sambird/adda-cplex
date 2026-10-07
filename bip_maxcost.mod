/*********************************************
 * OPL 22.1.1.0 Model
 * Author: sam
 * Creation Date: Feb 27, 2026 at 2:17:40 PM
 *********************************************/

execute {
  cplex.tilim = 3600;
}

int N_QUERIES = ...;
int N_UPDATES = ...;
int N_REPLICAS = ...;
int N_CANDIDATES = ...;
int MULTIPLICITY_FACTOR = ...;
float STORAGE_BUDGET = ...;

range Queries = 1..N_QUERIES;
range Updates = 1..N_UPDATES;
range Replicas = 1..N_REPLICAS;
range Indexes = 1..N_CANDIDATES;

float query_costs[Queries] = ...;
float query_benefits[Indexes][Queries] = ...;
float update_costs[Updates] = ...;
float update_benefits[Indexes][Updates] = ...;
float index_costs[Indexes] = ...;

// ignore
int LAM_ROUTING = ...;
int LAM_REPLICA = ...;

dvar float z;
dvar int x[Indexes][Replicas] in 0..1;
dvar int t[Queries][Replicas] in 0..1;

minimize z;

subject to {
  forall(r in Replicas)
    ctMax:
      z - sum(q in Queries)(
        (query_costs[q]
        + sum(i in Indexes)(
            -1*query_benefits[i][q] * x[i][r]
        )) * t[q][r] * (1 / MULTIPLICITY_FACTOR)
      )
      - sum(u in Updates)(
          update_costs[u]
          + sum(i in Indexes)(
              update_benefits[i][u] * x[i][r]
          )
      ) >= 0;
    
  
  forall(q in Queries)
    ctMultiplicity:
        sum(r in Replicas)
          t[q][r] == MULTIPLICITY_FACTOR;
   
  forall(r in Replicas)
    ctStorage:
        sum(i in Indexes)
          index_costs[i] * x[i][r] <= STORAGE_BUDGET;
}

execute DISPLAY_REPLICA_COSTS {
  for (var r in Replicas) {
    var queryTerm = 0;
    for (var q in Queries) {
      var benefitSum = 0;
      for (var i in Indexes) {
        benefitSum += -1 * query_benefits[i][q] * x[i][r];
      }
      queryTerm += (query_costs[q] + benefitSum) * t[q][r] * (1 / MULTIPLICITY_FACTOR);
    }

    var updateTerm = 0;
    for (var u in Updates) {
      var updateBenefitSum = 0;
      for (var i in Indexes) {
        updateBenefitSum += update_benefits[i][u] * x[i][r];
      }
      updateTerm += update_costs[u] + updateBenefitSum;
    }
    
    var indexCost = 0;
    for (var i in Indexes) {
      indexCost += index_costs[i] * x[i][r];
    }

    var replicaCost = queryTerm - updateTerm;
    writeln("Replica " + r + ": workload cost = " + replicaCost + ", index cost = " + indexCost);
  }
}
execute VERIFY_ROUTING_FEASIBLE {
  for (var q in Queries) {
    var num_found = 0;

    for (var r in Replicas) {
      num_found += t[q][r];
    }
    
    if (num_found != MULTIPLICITY_FACTOR) {
      writeln("!! solution infeasible at query " + q);
    }
  }
}
execute DISPLAY_RESULT {
  writeln("index candidates (x)");
  for (var i in Indexes) {
    write("idx_" + (i - 1) + ",");
    for (var r in Replicas) {
      if (x[i][r] == 1) {
        write("" + r - 1 + ",");
      }
    } 
    writeln("");
  }     
  writeln("routing function (t)");
  for (var q in Queries) {
    for (var r in Replicas) {
      if (t[q][r] == 1) {
        write("" + r - 1);
      }   
    }         
    write(",");
  }   
  writeln("");
}
