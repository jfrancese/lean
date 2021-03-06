import ground_zero.types.heq

/-
  Pushout.
  * HoTT 6.8
-/

namespace ground_zero
namespace HITs

universes u v w k

section
  parameters {α : Type u} {β : Type v} {σ : Type k} (f : σ → α) (g : σ → β)
  inductive pushout_rel : (α ⊕ β) → (α ⊕ β) → Prop
  | mk {} : Π (x : σ), pushout_rel (sum.inl (f x)) (sum.inr (g x))
  def pushout := quot pushout_rel
end

namespace pushout
  -- https://github.com/leanprover/lean2/blob/master/hott/hit/pushout.hlean
  variables {α : Type u} {β : Type v} {σ : Type k} {f : σ → α} {g : σ → β}
  def inl (x : α) : pushout f g :=
  quot.mk (pushout_rel f g) (sum.inl x)

  def inr (x : β) : pushout f g :=
  quot.mk (pushout_rel f g) (sum.inr x)

  def glue (x : σ) : inl (f x) = inr (g x) :> pushout f g :=
  support.inclusion (quot.sound $ pushout_rel.mk x)

  def ind {δ : pushout f g → Type w}
    (inl₁ : Π (x : α), δ (inl x)) (inr₁ : Π (x : β), δ (inr x))
    (glue₁ : Π (x : σ), inl₁ (f x) =[glue x] inr₁ (g x)) :
    Π (x : pushout f g), δ x := begin
    intro h, refine quot.hrec_on h _ _,
    { intro x, induction x, exact inl₁ x, exact inr₁ x },
    { intros u v H, cases H with x, simp,
      apply types.heq.from_pathover (glue x),
      exact glue₁ x }
  end

  def rec {δ : Type w} (inl₁ : α → δ) (inr₁ : β → δ)
    (glue₁ : Π (x : σ), inl₁ (f x) = inr₁ (g x) :> δ) :
    pushout f g → δ :=
  ind inl₁ inr₁ (λ x, types.dep_path.pathover_of_eq (glue x) (glue₁ x))
end pushout

end HITs
end ground_zero