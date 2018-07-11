class Camlp5TransitionalModeRequirement < Requirement
  fatal true

  satisfy(:build_env => false) { !Tab.for_name("camlp5").with?("strict") }

  def message; <<~EOS
    camlp5 must be compiled in transitional mode (instead of --strict mode):
      brew install camlp5
  EOS
  end
end

class Coq < Formula
  desc "Proof assistant for higher-order logic"
  homepage "https://coq.inria.fr/"
  url "https://github.com/coq/coq/archive/V8.8.1.tar.gz"
  sha256 "c852fef30f511135993bc9dbed299849663d0096a72bf0797a133f86deda9e8d"
  head "https://github.com/coq/coq.git"

  bottle do
    rebuild 1
    sha256 "55ddb9b56df4c5a897f71adc8960dc5cd53c9eda180152507174accb27c94f1a" => :high_sierra
    sha256 "bfc2d659c796d7f9bf9ae89a89d1d99095965d50c63c61fa6a00703f67958588" => :sierra
    sha256 "1c81e04c0343de53b8843705025c41d0d6baa7810f3938e76c18ca0d4070da83" => :el_capitan
  end

  depends_on "ocaml-findlib" => :build
  depends_on Camlp5TransitionalModeRequirement
  depends_on "camlp5"
  depends_on "ocaml"
  depends_on "ocaml-num"

  def install
    system "./configure", "-prefix", prefix,
                          "-mandir", man,
                          "-emacslib", elisp,
                          "-coqdocdir", "#{pkgshare}/latex",
                          "-coqide", "no",
                          "-with-doc", "no"
    system "make", "world"
    ENV.deparallelize { system "make", "install" }
  end

  test do
    (testpath/"testing.v").write <<~EOS
      Require Coq.omega.Omega.
      Require Coq.ZArith.ZArith.

      Inductive nat : Set :=
      | O : nat
      | S : nat -> nat.
      Fixpoint add (n m: nat) : nat :=
        match n with
        | O => m
        | S n' => S (add n' m)
        end.
      Lemma add_O_r : forall (n: nat), add n O = n.
      Proof.
      intros n; induction n; simpl; auto; rewrite IHn; auto.
      Qed.

      Import Coq.omega.Omega.
      Import Coq.ZArith.ZArith.
      Open Scope Z.
      Lemma add_O_r_Z : forall (n: Z), n + 0 = n.
      Proof.
      intros; omega.
      Qed.
    EOS
    system("#{bin}/coqc", "#{testpath}/testing.v")
  end
end
