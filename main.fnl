(require :luacad)

(local my-cube (cube {:size [1 2 3]}))

(local my-sphere (sphere {:r 8}))
(my-sphere:translate 5 0 0)

(local model (+ my-cube my-sphere)) (model:export "main.scad")
true
