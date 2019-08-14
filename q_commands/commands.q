emp:([]name:(`tom`jack`nick`Linda);empid:(1 2 3 4);dept:(`sales`IT`finance`sales);salary:(5000 6000 7000 8000))
select sum(salary) by dept from emp
increment:{[x;y] x+x*y%100}
emp2: update salary:$[`int; increment[salary;15]] from emp
show emp2

