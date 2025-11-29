(require :luacad)

(local my-cube (cube {:size [1 2 3]}))

(local my-sphere (sphere {:r 8}))
(my-sphere:translate 5 0 0)

(local my-cylinder (cylinder {:r 8 :h 10}))
(my-cylinder:translate 0 5 0)

(let [model (+ my-cube my-sphere my-cylinder)]
  (model:export :main.scad))
true
