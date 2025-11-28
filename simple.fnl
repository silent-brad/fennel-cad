(require :luacad)

(let [my-cube (cube {:size [1 2 3]})
      my-sphere (fn [radius]
;; add translate (5 0 0)
                  (sphere {:r (* radius 2)}))
      model (+ my-cube (my-sphere 2))]
  (model:export "./simple.scad"))
