$title urban layout probelm with lagrangian relaxation algorithm
OPTIONS  ITERLIM=100000, RESLIM = 1000000, SYSOUT = OFF, SOLPRINT = OFF,  OPTCR= 0.01;

sets
i node /101,102,103,104,105,401,402,403,1001,1002,1*24/
m node types /home,office,other/
u attribute types /building,location,transport/
hb(i) home building /101,102,103,104,105/
hl(i) home location /3,8,18,20,21/
ol(i) office location /1,7,22/
ob(i) office building /401,402,403/
o(i) origin of super network /1001/
d(i) destination of super network /1002/;

alias (i,j);
alias (u,v);



parameter demand(i) /
1001  150
1002  150
/;

parameter origin_node(i) /
1001   1
/;

parameter destination_node(i) /
1002   1
/;

parameter fft(i,j)/
1.2         6
2.6         5
3.12        4
4.11        6
5.9         5
7.8         3
8.9        10
9.10        3
10.15       6
10.17       8
11.14       4
13.24       4
14.23       4
15.22       4
16.18       3
18.20       4
20.21       6
21.22       2
22.23       4
1.3         4
3.4         4
4.5         2
5.6         4
6.8         2
7.18        2
8.16        5
10.11       5
10.16       5
11.12       6
12.13       3
14.15       5
15.19       4
16.17       2
17.19       2
19.20       4
20.22       5
21.24       3
23.24       2
2.1         6
6.2         5
12.3        4
11.4        6
9.5         5
8.7         3
9.8        10
10.9        3
15.10       6
17.10       8
14.11       4
24.13       4
23.14       4
22.15       4
18.16       3
20.18       4
21.20       6
22.21       2
23.22       4
3.1         4
4.3         4
5.4         2
6.5         4
8.6         2
18.7        2
16.8        5
11.10       5
16.10       5
12.11       6
13.12       3
15.14       5
19.15       4
17.16       2
19.17       2
20.19       4
22.20       5
24.21       3
24.23       2
/;

parameter capacity(i,j)/
1001.101    10
1001.102    20
1001.103    30
1001.104    40
1001.105    50
101.3       10
101.18       10
101.8       10
101.20      10
101.21      10
102.3       20
102.18       20
102.8       20
102.20      20
102.21      20
103.3       30
103.18       30
103.8       30
103.20      30
103.21      30
104.3       40
104.18       40
104.8       40
104.20      40
104.21      40
105.3       50
105.18       50
105.8       50
105.20      50
105.21      50
1.401       40
7.401       40
22.401      40
1.402       50
7.402       50
22.402      50
1.403       60
7.403       60
22.403      60
401.1002    40
402.1002    50
403.1002    60
1.2         30
2.6         30
3.12        30
4.11        30
5.9         30
7.8         30
8.9         30
9.10        30
10.15       30
10.17       30
11.14       30
13.24       30
14.23       30
15.22       30
16.18       30
18.20       30
20.21       30
21.22       30
22.23       30
1.3         30
3.4         30
4.5         30
5.6         30
6.8         30
7.18        30
8.16        30
10.11       30
10.16       30
11.12       30
12.13       30
14.15       30
15.19      30
16.17       30
17.19       30
19.20       30
20.22       30
21.24       30
23.24       30
2.1         30
6.2         30
12.3        30
11.4        30
9.5         30
8.7         30
9.8         30
10.9        30
15.10       30
17.10       30
14.11       30
24.13       30
23.14      30
22.15       30
18.16       30
20.18       30
21.20       30
22.21       30
23.22       30
3.1         30
4.3         30
5.4         30
6.5         30
8.6         30
18.7        30
16.8        30
11.10       30
16.10       30
12.11       30
13.12       30
15.14       30
19.15       30
17.16       30
19.17       30
20.19       30
22.20       30
24.21       30
24.23       30
/;

parameter intermediate_node(i);
intermediate_node(i)=(1-origin_node(i))*(1-destination_node(i));

parameter pie(i,j);
pie(i,j)=0;

positive variable x(i,j) traffic flow between node i and node j;
positive variable x_lb(i,j);
binary variable y(i,j) wether there is an arc betwwen node i and j or not;
binary variable y_lb(i,j);
positive variable lamda(i,j) multipliers;
variable z,z_x,z_y  cost;

y.fx('1001','101')=1;
y_lb.fx('1001','101')=1;
y.fx('1001','102')=1;
y_lb.fx('1001','102')=1;
y.fx('1001','103')=1;
y_lb.fx('1001','103')=1;
y.fx('1001','104')=1;
y_lb.fx('1001','104')=1;
y.fx('1001','105')=1;
y_lb.fx('1001','105')=1;
y.fx('401','1002')=1;
y_lb.fx('401','1002')=1;
y.fx('402','1002')=1;
y_lb.fx('402','1002')=1;
y.fx('403','1002')=1;
y_lb.fx('403','1002')=1;
y.fx('1','2')=1;
y_lb.fx('1','2')=1;
y.fx('2','6')=1;
y_lb.fx('2','6')=1;
y.fx('3','12')=1;
y_lb.fx('3','12')=1;
y.fx('4','11')=1;
y_lb.fx('4','11')=1;
y.fx('5','9')=1;
y_lb.fx('5','9')=1;
y.fx('7','8')=1;
y_lb.fx('7','8')=1;
y.fx('8','9')=1;
y_lb.fx('8','9')=1;
y.fx('9','1')=1;
y_lb.fx('9','1')=1;
y.fx('10','15')=1;
y_lb.fx('10','15')=1;
y.fx('10','17')=1;
y_lb.fx('10','17')=1;
y.fx('11','14')=1;
y_lb.fx('11','14')=1;
y.fx('13','24')=1;
y_lb.fx('13','24')=1;
y.fx('14','23')=1;
y_lb.fx('14','23')=1;
y.fx('15','22')=1;
y_lb.fx('15','22')=1;
y.fx('16','18')=1;
y_lb.fx('16','18')=1;
y.fx('18','2')=1;
y_lb.fx('18','2')=1;
y.fx('20','21')=1;
y_lb.fx('20','21')=1;
y.fx('21','22')=1;
y_lb.fx('21','22')=1;
y.fx('22','23')=1;
y_lb.fx('22','23')=1;
y.fx('1','3')=1;
y_lb.fx('1','3')=1;
y.fx('3','4')=1;
y_lb.fx('3','4')=1;
y.fx('4','5')=1;
y_lb.fx('4','5')=1;
y.fx('5','6')=1;
y_lb.fx('5','6')=1;
y.fx('6','8')=1;
y_lb.fx('6','8')=1;
y.fx('7','18')=1;
y_lb.fx('7','18')=1;
y.fx('8','16')=1;
y_lb.fx('8','16')=1;
y.fx('10','11')=1;
y_lb.fx('10','11')=1;
y.fx('10','16')=1;
y_lb.fx('10','16')=1;
y.fx('11','12')=1;
y_lb.fx('11','12')=1;
y.fx('12','13')=1;
y_lb.fx('12','13')=1;
y.fx('14','15')=1;
y_lb.fx('14','15')=1;
y.fx('15','19')=1;
y_lb.fx('15','19')=1;
y.fx('16','17')=1;
y_lb.fx('16','17')=1;
y.fx('17','19')=1;
y_lb.fx('17','19')=1;
y.fx('19','2')=1;
y_lb.fx('19','2')=1;
y.fx('20','22')=1;
y_lb.fx('20','22')=1;
y.fx('21','24')=1;
y_lb.fx('21','24')=1;
y.fx('23','24')=1;
y_lb.fx('23','24')=1;
y.fx('2','1')=1;
y_lb.fx('2','1')=1;
y.fx('6','2')=1;
y_lb.fx('6','2')=1;
y.fx('12','3')=1;
y_lb.fx('12','3')=1;
y.fx('11','4')=1;
y_lb.fx('11','4')=1;
y.fx('9','5')=1;
y_lb.fx('9','5')=1;
y.fx('8','7')=1;
y_lb.fx('8','7')=1;
y.fx('9','8')=1;
y_lb.fx('9','8')=1;
y.fx('10','9')=1;
y_lb.fx('10','9')=1;
y.fx('15','1')=1;
y_lb.fx('15','1')=1;
y.fx('17','1')=1;
y_lb.fx('17','1')=1;
y.fx('14','11')=1;
y_lb.fx('14','11')=1;
y.fx('24','13')=1;
y_lb.fx('24','13')=1;
y.fx('23','14')=1;
y_lb.fx('23','14')=1;
y.fx('22','15')=1;
y_lb.fx('22','15')=1;
y.fx('18','16')=1;
y_lb.fx('18','16')=1;
y.fx('20','18')=1;
y_lb.fx('20','18')=1;
y.fx('21','2')=1;
y_lb.fx('21','2')=1;
y.fx('22','21')=1;
y_lb.fx('22','21')=1;
y.fx('23','22')=1;
y_lb.fx('23','22')=1;
y.fx('3','1')=1;
y_lb.fx('3','1')=1;
y.fx('4','3')=1;
y_lb.fx('4','3')=1;
y.fx('5','4')=1;
y_lb.fx('5','4')=1;
y.fx('6','5')=1;
y_lb.fx('6','5')=1;
y.fx('8','6')=1;
y_lb.fx('8','6')=1;
y.fx('18','7')=1;
y_lb.fx('18','7')=1;
y.fx('16','8')=1;
y_lb.fx('16','8')=1;
y.fx('11','1')=1;
y_lb.fx('11','1')=1;
y.fx('16','1')=1;
y_lb.fx('16','1')=1;
y.fx('12','11')=1;
y_lb.fx('12','11')=1;
y.fx('13','12')=1;
y_lb.fx('13','12')=1;
y.fx('15','14')=1;
y_lb.fx('15','14')=1;
y.fx('19','15')=1;
y_lb.fx('19','15')=1;
y.fx('17','16')=1;
y_lb.fx('17','16')=1;
y.fx('19','17')=1;
y_lb.fx('19','17')=1;
y.fx('20','19')=1;
y_lb.fx('20','19')=1;
y.fx('22','2')=1;
y_lb.fx('22','2')=1;
y.fx('24','21')=1;
y_lb.fx('24','21')=1;
y.fx('24','23')=1;
y_lb.fx('24','23')=1;
*y.fx('101','1')=1;
*y.fx('102','3')=1;
*y.fx('103','20')=1;
*y.fx('104','21')=1;
*y.fx('105','22')=1;
*y.fx('7','401')=1;
*y.fx('8','402')=1;
*y.fx('18','403')=1;


equations
cost
obj_flow
obj_assign
flow_on_node_origin(i)
flow_on_node_intermediate(i)
flow_on_node_destination(i)
lb_flow_on_node_origin(i)
lb_flow_on_node_intermediate(i)
lb_flow_on_node_destination(i)
arc_capacity(i,j)
*assign1(m,u,j)
*assign2(m,u,i)
assign_hb(i)
assign_hl(j)
assign_ob(j)
assign_ol(i)
lb_assign_hb(i)
lb_assign_hl(j)
lb_assign_ob(j)
lb_assign_ol(i)
;

cost..  z=e=sum((i,j),x(i,j)*fft(i,j));
obj_flow..   z_x=e=sum((i,j),x_lb(i,j)*(fft(i,j)+pie(i,j)));
obj_assign..  z_y=e=-sum((i,j),pie(i,j)*capacity(i,j)*y_lb(i,j));
flow_on_node_origin(i)$(origin_node(i)).. sum((j)$(capacity(i,j)>0.1), x(i,j)) =e= demand(i);
flow_on_node_destination(i)$(destination_node(i))..  sum((j)$(capacity(j,i)>0.1), x(j,i))=e= demand(i);
flow_on_node_intermediate(i)$(intermediate_node(i)).. sum((j)$(capacity(i,j)>0.1), x(i,j))-sum((j)$(capacity(j,i)>0.1),x(j,i))=e= 0;
arc_capacity(i,j)$(capacity(i,j)>0)..    x(i,j)=l=capacity(i,j)*y(i,j);
*assign1(m,u,j)$(node_type(m,'building',j))..  sum((i)$(node_type(m,'location',i)),y(i,j))=e=1;
*assign2(m,u,i)$(node_type(m,'location',i))..  sum((j)$(node_type(m,'building',j)),y(i,j))=e=1;
assign_hb(i)$(hb(i))..  sum(j$(hl(j)),y(i,j))=e=1;
assign_hl(j)$(hl(j))..  sum(i$(hb(i)),y(i,j))=e=1;
assign_ob(j)$(ob(j))..  sum(i$(ol(i)),y(i,j))=e=1;
assign_ol(i)$(ol(i))..  sum(j$(ob(j)),y(i,j))=e=1;
*flow balace of subproblem1
lb_flow_on_node_origin(i)$(origin_node(i)).. sum((j)$(capacity(i,j)>0.1), x_lb(i,j)) =e= demand(i);
lb_flow_on_node_destination(i)$(destination_node(i))..  sum((j)$(capacity(j,i)>0.1), x_lb(j,i))=e= demand(i);
lb_flow_on_node_intermediate(i)$(intermediate_node(i)).. sum((j)$(capacity(i,j)>0.1), x_lb(i,j))-sum((j)$(capacity(j,i)>0.1),x_lb(j,i))=e= 0;
*assignment constraints of subproblem2
lb_assign_hb(i)$(hb(i))..  sum(j$(hl(j)),y_lb(i,j))=e=1;
lb_assign_hl(j)$(hl(j))..  sum(i$(hb(i)),y_lb(i,j))=e=1;
lb_assign_ob(j)$(ob(j))..  sum(i$(ol(i)),y_lb(i,j))=e=1;
lb_assign_ol(i)$(ol(i))..  sum(j$(ob(j)),y_lb(i,j))=e=1;

model urban_layout /cost,flow_on_node_origin,flow_on_node_intermediate,flow_on_node_destination,arc_capacity,assign_hb,assign_hl,assign_ob,assign_ol/;
solve urban_layout using mip minimizing z;
display x.l, y.l, z.l;

File optimal_solution_SF1/optimal_solution_SF1.dat/;
Put optimal_solution_SF1;
put @1,'i',@6,'j',@17,'x.l(i,j)'/
loop((i,j)$(x.l(i,j)), put @1, i.tl, @6, j.tl, @11, x.l(i,j)/);
loop((i,j)$(y.l(i,j)), put @1, i.tl, @6, j.tl, @11, y.l(i,j)/);
put @1, 'z.l',@5, z.l ;

model subproblem1 /obj_flow,lb_flow_on_node_origin,lb_flow_on_node_intermediate,lb_flow_on_node_destination/;
model subproblem2 /obj_assign,lb_assign_hb,lb_assign_hl,lb_assign_ob,lb_assign_ol/;

parameter z_lb;

parameter step;
step = 1;

parameter n_value;
n_value = 1;

parameter n;
n= 0;

parameter zlbest;
zlbest=0;

parameter subgradient_pie(i,j);
subgradient_pie(i,j)=0;

sets iter  subgradient iteration index / iter1 * iter300/;

File output_lb_SF1/result_LR_SF1.txt/;
put output_lb_SF1;
put @10,'n',@27,'z_x.l',@47,'z_y.l',@67,'z_lb',@87,'zlbest' /

Loop (iter,
         solve subproblem1 using LP minimizing z_x;
         solve subproblem2 using MIP minimizing z_y;
         subgradient_pie(i,j)= x_lb.l(i,j)-capacity(i,j)*y_lb.l(i,j);
         pie(i,j)=max(0,pie(i,j)+step*subgradient_pie(i,j));
         n_value =n_value +1;
         step = step/(n+1);
         n=n_value-1;
         z_lb = z_x.l + z_y.l;
         zlbest = max(zlbest,z_lb);

         display z_x.l;
         display z_y.l;
         display x_lb.l;
         display y_lb.l;
         display subgradient_pie;
         display pie;
         display step;
         display z_lb;
         display zlbest;
         put @1,n,@20,z_x.l,@40,z_y.l,@60,z_lb,@80,zlbest /

);
