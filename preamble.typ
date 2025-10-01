#let font-text = ("Fira Sans", "Libertinus Serif")
#let font-math = ("Libertinus Math", "New Computer Modern Math")
#let font-monospace = ("Fira Code Arctic", "Fira Code", "DejaVu Sans Mono")

#let blue = rgb("#47A"); #let Blue = body => {
  set text(blue)
  body
}
#let cyan = rgb("#6CE"); #let Cyan = body => {
  set text(cyan)
  body
}
#let green = rgb("#283"); #let Green = body => {
  set text(green)
  body
}
#let yellow = rgb("#CB4"); #let Yellow = body => {
  set text(yellow)
  body
}
#let red = rgb("#E67"); #let Red = body => {
  set text(red)
  body
}
#let purple = rgb("#A37"); #let Purple = body => {
  set text(purple)
  body
}
#let gray = rgb("#BBB"); #let Gray = body => {
  set text(gray)
  body
}

#let preamble(body) = [
  #set page(margin: (left: 20mm, right: 20mm, top: 20mm, bottom: 20mm), numbering: "1", number-align: center)
  #set list(indent: 1em)
  #set enum(indent: 1em, numbering: "1.", full: true)

  #set text(font: font-text, lang: "en")
  #show raw: set text(font: font-monospace)
  #show math.equation: set text(font: font-math)

  #set par(leading: 0.85em, spacing: 1.25em)

  #body
]

#let a̅ = $overline(a)$; #let â = $hat(a)$; #let ã = $tilde(a)$
#let b̅ = $overline(b)$; #let b̂ = $hat(b)$; #let b̃ = $tilde(b)$
#let c̅ = $overline(c)$; #let ĉ = $hat(c)$; #let c̃ = $tilde(c)$
#let d̅ = $overline(d)$; #let d̂ = $hat(d)$; #let d̃ = $tilde(d)$
#let e̅ = $overline(e)$; #let ê = $hat(e)$; #let ẽ = $tilde(e)$
#let f̅ = $overline(f)$; #let f̂ = $hat(f)$; #let f̃ = $tilde(f)$
#let g̅ = $overline(g)$; #let ĝ = $hat(g)$; #let g̃ = $tilde(g)$
#let h̅ = $overline(h)$; #let ĥ = $hat(h)$; #let h̃ = $tilde(h)$
#let i̅ = $overline(i)$; #let î = $hat(i)$; #let ĩ = $tilde(i)$
#let j̅ = $overline(j)$; #let ĵ = $hat(j)$; #let j̃ = $tilde(j)$
#let k̅ = $overline(k)$; #let k̂ = $hat(k)$; #let k̃ = $tilde(k)$
#let l̅ = $overline(l)$; #let l̂ = $hat(l)$; #let l̃ = $tilde(l)$
#let m̅ = $overline(m)$; #let m̂ = $hat(m)$; #let m̃ = $tilde(m)$
#let n̅ = $overline(n)$; #let n̂ = $hat(n)$; #let ñ = $tilde(n)$
#let o̅ = $overline(o)$; #let ô = $hat(o)$; #let õ = $tilde(o)$
#let p̅ = $overline(p)$; #let p̂ = $hat(p)$; #let p̃ = $tilde(p)$
#let q̅ = $overline(q)$; #let q̂ = $hat(q)$; #let q̃ = $tilde(q)$
#let r̅ = $overline(r)$; #let r̂ = $hat(r)$; #let r̃ = $tilde(r)$
#let s̅ = $overline(s)$; #let ŝ = $hat(s)$; #let s̃ = $tilde(s)$
#let t̅ = $overline(t)$; #let t̂ = $hat(t)$; #let t̃ = $tilde(t)$
#let u̅ = $overline(u)$; #let û = $hat(u)$; #let ũ = $tilde(u)$
#let v̅ = $overline(v)$; #let v̂ = $hat(v)$; #let ṽ = $tilde(v)$
#let w̅ = $overline(w)$; #let ŵ = $hat(w)$; #let w̃ = $tilde(w)$
#let x̅ = $overline(x)$; #let x̂ = $hat(x)$; #let x̃ = $tilde(x)$
#let y̅ = $overline(y)$; #let ŷ = $hat(y)$; #let ỹ = $tilde(y)$
#let z̅ = $overline(z)$; #let ẑ = $hat(z)$; #let z̃ = $tilde(z)$
#let A̅ = $overline(A)$; #let Â = $hat(A)$; #let Ã = $tilde(A)$
#let B̅ = $overline(B)$; #let B̂ = $hat(B)$; #let B̃ = $tilde(B)$
#let C̅ = $overline(C)$; #let Ĉ = $hat(C)$; #let C̃ = $tilde(C)$
#let D̅ = $overline(D)$; #let D̂ = $hat(D)$; #let D̃ = $tilde(D)$
#let E̅ = $overline(E)$; #let Ê = $hat(E)$; #let Ẽ = $tilde(E)$
#let F̅ = $overline(F)$; #let F̂ = $hat(F)$; #let F̃ = $tilde(F)$
#let G̅ = $overline(G)$; #let Ĝ = $hat(G)$; #let G̃ = $tilde(G)$
#let H̅ = $overline(H)$; #let Ĥ = $hat(H)$; #let H̃ = $tilde(H)$
#let I̅ = $overline(I)$; #let Î = $hat(I)$; #let Ĩ = $tilde(I)$
#let J̅ = $overline(J)$; #let Ĵ = $hat(J)$; #let J̃ = $tilde(J)$
#let K̅ = $overline(K)$; #let K̂ = $hat(K)$; #let K̃ = $tilde(K)$
#let L̅ = $overline(L)$; #let L̂ = $hat(L)$; #let L̃ = $tilde(L)$
#let M̅ = $overline(M)$; #let M̂ = $hat(M)$; #let M̃ = $tilde(M)$
#let N̅ = $overline(N)$; #let N̂ = $hat(N)$; #let Ñ = $tilde(N)$
#let O̅ = $overline(O)$; #let Ô = $hat(O)$; #let Õ = $tilde(O)$
#let P̅ = $overline(P)$; #let P̂ = $hat(P)$; #let P̃ = $tilde(P)$
#let Q̅ = $overline(Q)$; #let Q̂ = $hat(Q)$; #let Q̃ = $tilde(Q)$
#let R̅ = $overline(R)$; #let R̂ = $hat(R)$; #let R̃ = $tilde(R)$
#let S̅ = $overline(S)$; #let Ŝ = $hat(S)$; #let S̃ = $tilde(S)$
#let T̅ = $overline(T)$; #let T̂ = $hat(T)$; #let T̃ = $tilde(T)$
#let U̅ = $overline(U)$; #let Û = $hat(U)$; #let Ũ = $tilde(U)$
#let V̅ = $overline(V)$; #let V̂ = $hat(V)$; #let Ṽ = $tilde(V)$
#let W̅ = $overline(W)$; #let Ŵ = $hat(W)$; #let W̃ = $tilde(W)$
#let X̅ = $overline(X)$; #let X̂ = $hat(X)$; #let X̃ = $tilde(X)$
#let Y̅ = $overline(Y)$; #let Ŷ = $hat(Y)$; #let Ỹ = $tilde(Y)$
#let Z̅ = $overline(Z)$; #let Ẑ = $hat(Z)$; #let Z̃ = $tilde(Z)$
#let Γ̅ = $overline(Γ)$; #let Γ̂ = $hat(Γ)$; #let Γ̃ = $tilde(Γ)$
#let Δ̅ = $overline(Δ)$; #let Δ̂ = $hat(Δ)$; #let Δ̃ = $tilde(Δ)$
#let Θ̅ = $overline(Θ)$; #let Θ̂ = $hat(Θ)$; #let Θ̃ = $tilde(Θ)$
#let Λ̅ = $overline(Λ)$; #let Λ̂ = $hat(Λ)$; #let Λ̃ = $tilde(Λ)$
#let Ξ̅ = $overline(Ξ)$; #let Ξ̂ = $hat(Ξ)$; #let Ξ̃ = $tilde(Ξ)$
#let Π̅ = $overline(Π)$; #let Π̂ = $hat(Π)$; #let Π̃ = $tilde(Π)$
#let Σ̅ = $overline(Σ)$; #let Σ̂ = $hat(Σ)$; #let Σ̃ = $tilde(Σ)$
#let ϒ̅ = $overline(ϒ)$; #let ϒ̂ = $hat(ϒ)$; #let ϒ̃ = $tilde(ϒ)$
#let Φ̅ = $overline(Φ)$; #let Φ̂ = $hat(Φ)$; #let Φ̃ = $tilde(Φ)$
#let Ψ̅ = $overline(Ψ)$; #let Ψ̂ = $hat(Ψ)$; #let Ψ̃ = $tilde(Ψ)$
#let Ω̅ = $overline(Ω)$; #let Ω̂ = $hat(Ω)$; #let Ω̃ = $tilde(Ω)$
#let α̅ = $overline(α)$; #let α̂ = $hat(α)$; #let α̃ = $tilde(α)$
#let β̅ = $overline(β)$; #let β̂ = $hat(β)$; #let β̃ = $tilde(β)$
#let γ̅ = $overline(γ)$; #let γ̂ = $hat(γ)$; #let γ̃ = $tilde(γ)$
#let δ̅ = $overline(δ)$; #let δ̂ = $hat(δ)$; #let δ̃ = $tilde(δ)$
#let ε̅ = $overline(ε)$; #let ε̂ = $hat(ε)$; #let ε̃ = $tilde(ε)$
#let ζ̅ = $overline(ζ)$; #let ζ̂ = $hat(ζ)$; #let ζ̃ = $tilde(ζ)$
#let η̅ = $overline(η)$; #let η̂ = $hat(η)$; #let η̃ = $tilde(η)$
#let θ̅ = $overline(θ)$; #let θ̂ = $hat(θ)$; #let θ̃ = $tilde(θ)$
#let ι̅ = $overline(ι)$; #let ι̂ = $hat(ι)$; #let ι̃ = $tilde(ι)$
#let κ̅ = $overline(κ)$; #let κ̂ = $hat(κ)$; #let κ̃ = $tilde(κ)$
#let λ̅ = $overline(λ)$; #let λ̂ = $hat(λ)$; #let λ̃ = $tilde(λ)$
#let μ̅ = $overline(μ)$; #let μ̂ = $hat(μ)$; #let μ̃ = $tilde(μ)$
#let ν̅ = $overline(ν)$; #let ν̂ = $hat(ν)$; #let ν̃ = $tilde(ν)$
#let ξ̅ = $overline(ξ)$; #let ξ̂ = $hat(ξ)$; #let ξ̃ = $tilde(ξ)$
#let π̅ = $overline(π)$; #let π̂ = $hat(π)$; #let π̃ = $tilde(π)$
#let ρ̅ = $overline(ρ)$; #let ρ̂ = $hat(ρ)$; #let ρ̃ = $tilde(ρ)$
#let σ̅ = $overline(σ)$; #let σ̂ = $hat(σ)$; #let σ̃ = $tilde(σ)$
#let τ̅ = $overline(τ)$; #let τ̂ = $hat(τ)$; #let τ̃ = $tilde(τ)$
#let υ̅ = $overline(υ)$; #let υ̂ = $hat(υ)$; #let υ̃ = $tilde(υ)$
#let φ̅ = $overline(φ)$; #let φ̂ = $hat(φ)$; #let φ̃ = $tilde(φ)$
#let χ̅ = $overline(χ)$; #let χ̂ = $hat(χ)$; #let χ̃ = $tilde(χ)$
#let ψ̅ = $overline(ψ)$; #let ψ̂ = $hat(ψ)$; #let ψ̃ = $tilde(ψ)$
#let ω̅ = $overline(ω)$; #let ω̂ = $hat(ω)$; #let ω̃ = $tilde(ω)$
