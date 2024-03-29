;; Copyright Barbara Kamińska 2024;;
;; Initial version Bartłomiej Nowak 2021;;
;; implementation of Watts-Strogatz network taken from https://github.com/fsancho/Complex-Networks-Toolbox/blob/master/Complex%20Networks%20Model%206.nlogo


globals [greens greens_1000 avg_greens target q_voters]
turtles-own [p_]

to setup
  clear-all
  ask patches [set pcolor white]
  set-default-shape turtles "spinson"
  create-turtles N [
    set size 2
    ifelse (random 100) < density_of_adopters
    [set color green]
    [set color red]
    ifelse (disorder = "annealed")
    [set p_ p]
    [
      ifelse random-float 1.0 < p
      [set p_ 1]
      [set p_ 0]
    ]
  ]
  layout-circle sort turtles 14
  ;; initial wiring
  let neigh (n-values (k / 2) [ [i] -> i + 1 ])
  ifelse k < N [
  ask turtles [
    let tar who
    foreach neigh [ [i] -> create-link-with (turtle ((tar + i) mod N)) ]
  ]
  ;; rewiring
  ask links [
    let if_rewired false
    if (random-float 1) < beta[
      let node1 end1
      if [ count link-neighbors ] of node1 < (N - 1) [
        let node2 one-of turtles with [ (self != node1) and (not link-neighbor? node1)]
        ask node1 [ create-link-with node2 [ set if_rewired true ] ]
      ]
    ]
    if (if_rewired)[
      die
    ]
  ]
  ][
    display
    user-message (word "Select k < N")

  ]
  ask turtles [ set label-color black ]
  set q_voters nobody
  set greens []
  set greens_1000 []
  set avg_greens 0
  reset-ticks
end

to step1
  ask links [set color gray set thickness 0.1]
  ask turtles
  [
    set shape "spinson"
  ]
  set target random N
  ask turtle target
  [
    set shape "circle"
    ;wait 5
    ask my-links [set color black set thickness 0.2]
  ]
end

to step2
  if q_voters != nobody [
    ask q_voters[
      set shape "spinson"
    ]
  ]
    ask turtle target [
      if (count link-neighbors) >= q
      [
        set q_voters n-of q link-neighbors
        ask q_voters [set shape "x"]
      ]
    ]
end

to step3
  clear-output
  let p_current ([p_] of turtle target)
  ifelse random-float 1 < p_current
    [ ;; independence
      output-print "Independence"
      ifelse random-float 1.0 < pi_
      [ask turtle target [set color green] ]
      [ask turtle target [set color red] ]
    ]
    [ ;; conformity
      ifelse q_voters != nobody [
        output-print "Conformity"
        if (all? q_voters [color = green]) [ask turtle target [set color green]]
        if (all? q_voters [color = red]) [ask turtle target [set color red]]
      ]
      [
        output-print "Conformity \nq-panel not selected \nPossibly too few \nneighbors"
      ]
    ]
end

to go
  repeat N [
    ask links [set color gray set thickness 0.1]
    ask turtles
    [
      set shape "spinson"
    ]
    set target random N
    ask turtle target
    [
      set shape "circle"
      ;wait 5
      ask my-links [set color black set thickness 0.2]
      let p_current p_
      ifelse random-float 1 < p_current
      [ ;; independence
        ifelse random-float 1.0 < pi_
        [ask turtle target [set color green] ]
        [ask turtle target [set color red] ]
      ]
      [ ;; conformity
        let gpanel 0
        let rpanel 0
        if (count link-neighbors) >= q
        [
          let q-voters n-of q link-neighbors
          ask q-voters [set shape "x"]
          if (all? q-voters [color = green]) [ask turtle target [set color green]]
          if (all? q-voters [color = red]) [ask turtle target [set color red]]
        ]
      ]
    ]
  ]
  ifelse (ticks > 1000) [
    set greens lput (count turtles with [color = green] / N) greens
    ifelse (length greens_1000 > 1000) [
      set greens_1000 lput (count turtles with [color = green] / N) greens_1000
      set greens_1000 but-first greens_1000
      set avg_greens ((sum greens_1000) / 1000)
    ] [
      set greens_1000 lput (count turtles with [color = green] / N) greens
    ]
  ] [
    set greens lput (count turtles with [color = green] / N) greens
  ]
  tick
end
@#$#@#$#@
GRAPHICS-WINDOW
250
12
630
393
-1
-1
12.0
1
10
1
1
1
0
0
0
1
-15
15
-15
15
1
1
1
ticks
30.0

BUTTON
11
403
74
436
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
79
403
142
436
NIL
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
147
403
237
436
go forever
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
12
362
184
395
density_of_adopters
density_of_adopters
0
100
60.0
1
1
%
HORIZONTAL

SLIDER
12
36
184
69
N
N
10
101
101.0
1
1
NIL
HORIZONTAL

PLOT
643
12
979
281
Time evolution
Time
Concentration of greens/reds
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"greens" 1.0 0 -13840069 true "" "plot count turtles with [color = green] / N"
"reds" 1.0 0 -2674135 true "" "plot count turtles with [color = red] / N"

TEXTBOX
251
398
622
499
Legend:\no = target agent\nx = source of influence (q-panel)\nthick lines = links to nearest neighbors of target agent
14
0.0
0

SLIDER
12
71
184
104
k
k
2
N - 1
100.0
1
1
NIL
HORIZONTAL

TEXTBOX
15
13
165
31
Network parameters
14
0.0
1

SLIDER
12
106
184
139
beta
beta
0
1
0.49
0.01
1
NIL
HORIZONTAL

SLIDER
11
169
183
202
q
q
1
N - 1
4.0
1
1
NIL
HORIZONTAL

SLIDER
11
204
183
237
p
p
0
1
0.1
0.01
1
NIL
HORIZONTAL

TEXTBOX
13
148
163
166
Model parameters
14
0.0
1

TEXTBOX
15
340
165
358
Initial contidions
14
0.0
1

MONITOR
250
481
630
538
Average concentration of greens in last 1000 steps
avg_greens
2
1
14

BUTTON
11
462
76
495
target
step1
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
82
462
156
495
q-panel
step2
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
163
462
234
495
update
step3
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

OUTPUT
10
500
234
586
11

TEXTBOX
15
441
165
459
Algorithm step-by-step
14
0.0
1

SLIDER
12
240
184
273
pi_
pi_
0
1
0.75
0.01
1
NIL
HORIZONTAL

CHOOSER
11
280
149
325
disorder
disorder
"annealed" "quenched"
0

@#$#@#$#@
## WHAT IS IT?

The q-voter model with independence [3] is a model of opinion dynamics in which each agent verbalizes an opinion on a two-point scale [1, -1], such as yes/no, for/against or in the case of innovation diffusion adopters/non-adopters. There are two types of social responses in the model, conformity and independence.
Conformism, which means yielding to the influence of others and adopting their opinions, was introduced in line with the results of the classic Asch experiment, which showed that by far the strongest group influence occurs when the group is unanimous [1]. Independence, on the other hand, involves not taking into account the opinions of others. The model was proposed by physicists and it resembles the famous Ising model. 

Here we present an extension, where in the case of independent behavior, the probabilities of changing opinion to 1 and -1 may not be the same.

Furthermore, we allow also to explore the differences between quenched and annealed disorder, in social sciences known as person-situation debate. 
 
## HOW IT WORKS

We consider a population of agents on a network of size N. In this implementation we use the Watts-Strogatz network, which is described by two parameters: k (the average degree of the node) and beta (probability of rewiring). Each agent can be in one of two states +1 or -1 (e.g. adopter / non-adopter), which is marked in green or red, respectively. There are two parameters of the model: q (the size of the influence group) and p (probability of independent behavior). Time evolution of the systems is given by the following ALGORITHMS:

ANEALED DISORDER (SITUATION SCENARIO) 
0) Set parameters of the network and the model, as well as the initial conditions; set counter time = 0
1) Randomly choose an agent, from all N agents, who reconsiders its opinion, we  call it "target" and update  counter time = time + 1/N
2) With probability p target behaves independently, so it does not take into account opinions of others. With probability pi_ it changes opinion to 1 (adopt) and with complementary probability 1-pi_ it changes opinion to -1 (withdraw adoption). 
3) With complementary probability (1-p) it is susceptible to influence exerted by its neighbors (agents that are directly linked to the target). In such a case it  randomly chooses q among all its neighbors. If all of them have the same opinion, the target conforms and follows adoption decision of the group.
4) Go to 1


QUENCHED DISORDER (PERSON SCENARIO) 
0) Set parameters of the network and the model, as well as the initial conditions; 
assign agents their behaviors: with probability p an agent becomes independent, with complementary probability (1-p) it becomes conformist; 
set counter time = 0
1) Randomly choose an agent, from all N agents, who reconsiders its opinion, we  call it "target" and update  counter time = time + 1/N. If target is independent go to 2. Otherwise, go to 3
2) Target behaves independently, so it does not take into account opinions of others. With probability pi_ it changes opinion to 1 (adopt) and with complementary probability 1-pi_ it changes opinion to -1 (withdraw adoption) 
3) Target is susceptible to influence exerted by its neighbors (agents that are directly linked to the target). In such a case it  randomly chooses q among all its neighbors. If all of them have the same opinion, the target conforms and takes the opinion of the group
4) Go to 1

## HOW TO USE IT

NETWORK PARAMETERS
The model is implemented on the Watts-Strogatz network, therefore first choose parameters of the network:

  * N - number of agents
  * k - the average degree of the node (note that k should be an even number; in the case of odd number the average degree will be k-1; for complete graph, choose k = N - 1)
  * beta - probability of rewiring


MODEL PARAMETERS
Choose parameters of the model:

  * q - size of the influence group
  * p - the probability of independence
  * pi_ - the probability of changing opinion to 1 (adopt)
  * type of disorder (annealed - "situation scenario" or quenched - "person scenario")

INITIAL CONDITIONS
The last thing to choose is the initial fraction of agents with positive opinion given by parameter:

  * density_of_adopters - the fraction of greens (positive opinions) at the beginning of simulations; greens are randomly distributed over the whole system.
 
After choosing values of all parameters click:
1) "setup" - to set all values of parameters (step 0 of the ALGORITHM described in Section HOW IT WORKS)
2) "go" - to see the evolution of the system within single update (steps 1-3 of the ALGORITHM described in Section HOW IT WORKS)
3) "go forever" - to run the model according to steps 1-4 of the ALGORITHM described in Section HOW IT WORKS

Algorithm can be also observed in the step-by-step section by clicking one by one the following buttons: 
1) "target" - an agent, which opinion will be updated is selected. Thick black lines indicate the target's neighbors. 
2) "q-panel" -  q agents among all target's neighbors are randomly selected, they are marked with X
3) "update" -  target updates it opinion according to the ALGORITHM described in Section HOW IT WORKS
The monitor displays which behavior worked - conformity or independence. 


## THINGS TO NOTICE

You can observe the phenomenon of critical mass. In the context of diffusion of innovations it means that spread of the product requires big enough group of initial adopters.

It can be shown with this model by setting the following parameters:

  * N = 101
  * k = 100
  * q = 4
  * p = 0.1
  * pi_ = 0.75
  * annealed disorder

Play with different initial conditions:
set density_of_adopters below and above 0.4, for instance:

  * density_of_adopters = 0.2 - you should observe that only small fraction of all agents will adopt (concentration of adopters yields around 0.11)
  * density_of_adopters = 0.6 - most of the agents become adopters (around 0.97)


 

## EXTENDING THE MODEL

One can extend the model by replacing the underlaying structure with another random networks such as Erdos-Renyi or Barabasi-Albert. 


## HOW TO CITE



## ACKNOWLEDGEMENT 

This model was created as part of the project funded by the National Science Center (NCN, Poland) through grant no. 2019/35/B/HS6/02530 

## CREDITS AND REFERENCES

[1] Asch, S. E. (1955). Opinions and social pressure. Scientific American, 193(5), 31–35.
[2] C. Castellano, M.A. Muñoz, R. Pastor-Satorras, Nonlinear q -voter model. Physical review. E, 10 2009.
[3] P. Nyczka, K. Sznajd-Weron, J. Cisło, Phase transitions in the q-voter model with two types of stochastic driving. Phys. Rev. E, 07 2012
[4] 

<!-- 2023 -->
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

spinson
false
0
Circle -7500403 true true 113 1 74
Polygon -7500403 true true 120 75 30 165 60 195 120 135 120 285 180 285 180 135 240 195 270 165 180 75 150 105 150 105

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.3.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
