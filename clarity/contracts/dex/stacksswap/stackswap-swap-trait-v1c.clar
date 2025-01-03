(use-trait sip-010-token .sip-010-v1a.sip-010-trait)
(use-trait liquidity-token .liquidity-token-trait-v4c.liquidity-token-trait)

(define-trait stackswap-swap
  (
    (create-pair (<sip-010-token> <sip-010-token> <liquidity-token> (string-ascii 32) uint uint) (response bool uint))

    (add-to-position (<sip-010-token> <sip-010-token> <liquidity-token> uint uint)  (response bool uint))

    (reduce-position (<sip-010-token> <sip-010-token> <liquidity-token> uint)  (response (list 2 uint) uint))

    (swap-x-for-y (<sip-010-token> <sip-010-token> <liquidity-token> uint uint)  (response (list 2 uint) uint))

    (swap-y-for-x (<sip-010-token> <sip-010-token> <liquidity-token> uint uint)  (response (list 2 uint) uint))
  )
)