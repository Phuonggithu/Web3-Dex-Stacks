

(use-trait ft-trait .trait-sip-010.sip-010-trait)

(define-constant ONE_8 u100000000) ;; 8 decimal places
(define-constant ERR-NOT-AUTHORIZED (err u1000))

;; entrance 
;; poolType, swapFuncType, fromToken, toToken, weightX, weightY, dx, minDy => (dx, dy)
;;(batches (list 3 {pool: principal,poolType: uint, swapType: uint, fromToken: <ft-trait>, toToken: <ft-trait>,weight-x: uint, weight-y: uint, dx: uint, min-dy: (optional uint)}))

(define-trait DispatcherInterface 
    (
        (swap 
            ;; ({poolType: uint, swapFuncType: uint, fromToken: <ft-trait>, toToken: <ft-trait>, weightX: uint, weightY: uint, dx: uint, minDy: (optional uint)})
            (uint uint <ft-trait> <ft-trait> uint uint uint (optional uint))
            (response uint uint)
        )
    )
)

(define-data-var dispatcher principal tx-sender)
(define-data-var contract-owner principal tx-sender)

(define-read-only (get-contract-owner)
  (ok (var-get contract-owner))
)

(define-public (set-contract-owner (owner principal))
  (begin
    (try! (check-is-owner)) 
    (ok (var-set contract-owner owner))
  )
)

(define-read-only (get-dispatcher)
    (ok (var-get dispatcher))
)
(define-public (set-dispatcher (dispatcherImpl principal))
    (begin
        (try! (check-is-owner))
        (ok (var-set dispatcher dispatcherImpl))
    )
)

(define-private (check-is-owner)
  (ok (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED))
)


(define-constant ERR_BATCH_LENGTH (err u1001))
(define-constant ERR_INVALID_BATCH (err u1002))
(define-constant ERR_DISPATCH_FAILED (err u1003))
(define-constant ERR_RETURN_AMOUNT_IS_NOT_ENOUGH (err u1004))
(define-constant ERR_BALANCE_ERROR (err u1005))
(define-constant ERR_JUMP_FAILED (err u1006))
(define-constant ERR_NOT_OK (err u1007))
(define-public (unxswap 
    (baseRequest {fromToken: <ft-trait>, toToken: <ft-trait>, fromTokenAmount: uint, minReturnAmount: uint}) 
    (batches (list 3 {dexType: uint, poolType: uint, swapFuncType: uint, fromToken: <ft-trait>, toToken: <ft-trait>, weightX: uint, weightY: uint, dx: uint, minDy: (optional uint)}))
    )

    (let
      (
          (batchLen (len batches))
          (toToken (get toToken baseRequest))
          (fromTokenAmount (get fromTokenAmount baseRequest))
          (minReturnAmount (get minReturnAmount baseRequest))
          (sender tx-sender)
          (balanceBefore (try! (contract-call? toToken get-balance sender)))
      )
      (asserts! (and (<= batchLen u3) (>= batchLen u1)) ERR_BATCH_LENGTH)

      (try! (fold handleJump batches (ok fromTokenAmount)))
      ;; return amount delta
      (checkMinReturn (try! (contract-call? toToken get-balance sender)) balanceBefore minReturnAmount)
    )


)
(define-private (checkMinReturn (balanceAfter uint) (balanceBefore uint) (minReturnAmount uint)) 
    (begin 
        (asserts! (>= balanceAfter balanceBefore) ERR_BALANCE_ERROR)
        (asserts! (>= (- balanceAfter balanceBefore) minReturnAmount) ERR_RETURN_AMOUNT_IS_NOT_ENOUGH)
        (print {balanceAfter: balanceAfter, balanceBefore: balanceBefore, minReturnAmount: minReturnAmount})
        (ok (- balanceAfter balanceBefore))
    )
    
)


(define-public (handleJump 
    (batch {dexType: uint, poolType: uint, swapFuncType: uint, fromToken: <ft-trait>, toToken: <ft-trait>, weightX: uint, weightY: uint, dx: uint, minDy: (optional uint)})
    (priorRes (response uint uint))
) 
(match priorRes
    amountIn 
    (let
        (
        ;;   (batchInfo (unwrap! batch0 ERR_INVALID_BATCH))
        (batchInfo (merge batch {dx: amountIn}))
        (dexType (get dexType batchInfo))
        (poolType (get poolType batchInfo))
        (swapFuncType (get swapFuncType batchInfo))
        (fromToken (get fromToken batchInfo))
        (toToken (get toToken batchInfo))
        (weightX (get weightX batchInfo))
        (weightY (get weightY batchInfo))
        (dx (get dx batchInfo))
        (minDy (get minDy batchInfo))
        ;; 0xAAAA 0xBBBB.dispatcher
        (dy (get dy (try! (contract-call? .alexAdapter swap
                poolType swapFuncType fromToken toToken weightX weightY dx minDy
            ))))
        )
        (asserts! (>= dy (default-to u0 minDy)) ERR_RETURN_AMOUNT_IS_NOT_ENOUGH)
        (ok dy)
    )
    err-value (err err-value)
)
 
)

;; (define-public (handleJump0 
;;     (batch0 (optional {dexType: uint, poolType: uint, swapFuncType: uint, fromToken: <ft-trait>, toToken: <ft-trait>, weightX: uint, weightY: uint, dx: uint, minDy: (optional uint)})) 
;;     (amountIn uint)
;; ) 
;;   (let
;;     (
;;     ;;   (batchInfo (unwrap! batch0 ERR_INVALID_BATCH))
;;       (batchInfo (merge (unwrap! batch0 ERR_INVALID_BATCH) {dx: amountIn}))
;;       (dexType (get dexType batchInfo))
;;       (poolType (get poolType batchInfo))
;;       (swapFuncType (get swapFuncType batchInfo))
;;       (fromToken (get fromToken batchInfo))
;;       (toToken (get toToken batchInfo))
;;       (weightX (get weightX batchInfo))
;;       (weightY (get weightY batchInfo))
;;       (dx (get dx batchInfo))
;;       (minDy (get minDy batchInfo))
;;       ;; 0xAAAA 0xBBBB.dispatcher
;;       (dy (get dy (try! (contract-call? .alexAdapter swap
;;         ;;  (get dexType batchInfo)
;;         ;;  (get poolType batchInfo)
;;         ;;  (get swapFuncType batchInfo)
;;         ;;  (get fromToken batchInfo)
;;         ;;  (get toToken batchInfo)
;;         ;;  (get weightX batchInfo)
;;         ;;  (get weightY batchInfo)
;;         ;;  (get dx batchInfo)
;;         ;;  (get minDy batchInfo)
;;             ;; dexType 
;;             poolType swapFuncType fromToken toToken weightX weightY dx minDy
;;          ))))
;;     )
;;     (asserts! (>= dy (default-to u0 minDy)) ERR_RETURN_AMOUNT_IS_NOT_ENOUGH)
;;     (ok {dx: dx, dy: dy})
;;   )
;; )

