

(use-trait ft-trait .trait-sip-010.sip-010-trait)

(define-constant ONE_8 u100000000) ;; 8 decimal places
(define-constant ERR-NOT-AUTHORIZED (err u1000))

;; entrance 
;; poolId, swapId, fromToken, toToken, weightX, weightY, dx, minDy => (dx, dy)
;;(batches (list 3 {pool: principal,poolType: uint, swapType: uint, fromToken: <ft-trait>, toToken: <ft-trait>,weight-x: uint, weight-y: uint, dx: uint, min-dy: (optional uint)}))

(define-trait DispatcherInterface 
    (
        (swap 
            ;; ({poolId: uint, swapId: uint, fromToken: <ft-trait>, toToken: <ft-trait>, weightX: uint, weightY: uint, dx: uint, minDy: (optional uint)})
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


(define-constant ERR_BATCH_LENGTH_EXCEED (err u1001))
(define-constant ERR_INVALID_BATCH (err u1002))
(define-constant ERR_DISPATCH_FAILED (err u1003))
(define-constant ERR_RETURN_AMOUNT_IS_NOT_ENOUGH (err u1004))
(define-constant ERR_BALANCE_ERROR (err u1005))
(define-constant ERR_JUMP_FAILED (err u1006))
(define-public (unxswap 
    (baseRequest {fromToken: <ft-trait>, toToken: <ft-trait>, fromTokenAmount: uint, minReturnAmount: uint}) 
    (batches (list 3 {dexType: uint, poolId: uint, swapId: uint, fromToken: <ft-trait>, toToken: <ft-trait>, weightX: uint, weightY: uint, dx: uint, minDy: (optional uint)}))
    )

    (let
      (
          (batchLen (len batches))
          (fromToken (get fromToken baseRequest))
          (toToken (get toToken baseRequest))
          (fromTokenAmount (get fromTokenAmount baseRequest))
          (minReturnAmount (get minReturnAmount baseRequest))
          (batches0 (element-at? batches u0))
          (batches1 (element-at? batches u1))
          (batches2 (element-at? batches u2))
          ;; (dispatcherImpl (var-get dispatcher))
          (sender tx-sender)
          (balanceBefore (try! (contract-call? toToken get-balance sender)))
      )
      (asserts! (and (<= batchLen u3) (>= batchLen u1)) ERR_BATCH_LENGTH_EXCEED)
      (if (is-eq batchLen u1) 
          (get dy (try! (handleJump0 batches0)))
          (if (is-eq batchLen u2)
              (get dy (try! (handleJump1 batches0 batches1)))
              (if (is-eq batchLen u3)
                  (get dy (try! (handleJump2 batches0 batches1 batches2)))
                  u0
              )      
          )
      )
      ;; return amount delta
      (checkMinReturn (try! (contract-call? toToken get-balance sender)) balanceBefore minReturnAmount)
    )


)
(define-private (checkMinReturn (balanceAfter uint) (balanceBefore uint) (minReturnAmount uint)) 
    (begin 
        (asserts! (>= balanceAfter balanceBefore) ERR_BALANCE_ERROR)
        (asserts! (>= (- balanceAfter balanceBefore) minReturnAmount) ERR_RETURN_AMOUNT_IS_NOT_ENOUGH)
        (ok (- balanceAfter balanceBefore))
    )
    
)

(define-private (handleJump0 (batch0 (optional {dexType: uint, poolId: uint, swapId: uint, fromToken: <ft-trait>, toToken: <ft-trait>, weightX: uint, weightY: uint, dx: uint, minDy: (optional uint)}))) 
  (let
    (
      (batchInfo (unwrap! batch0 ERR_INVALID_BATCH))
      (dexType (get dexType batchInfo))
      (poolId (get poolId batchInfo))
      (swapId (get swapId batchInfo))
      (fromToken (get fromToken batchInfo))
      (toToken (get toToken batchInfo))
      (weightX (get weightX batchInfo))
      (weightY (get weightY batchInfo))
      (dx (get dx batchInfo))
      (minDy (get minDy batchInfo))
      ;; 0xAAAA 0xBBBB.dispatcher
      (dy (get dy (try! (contract-call? .dispatcher swap dexType poolId swapId fromToken toToken weightX weightY dx minDy))))
    )
    (asserts! (>= dy (default-to u0 minDy)) ERR_RETURN_AMOUNT_IS_NOT_ENOUGH)
    (ok {dx: dx, dy: dy})
  )

)
(define-private (handleJump1 
    (batch0 (optional {dexType: uint, poolId: uint, swapId: uint, fromToken: <ft-trait>, toToken: <ft-trait>, weightX: uint, weightY: uint, dx: uint, minDy: (optional uint)}))
    (batch1 (optional {dexType: uint, poolId: uint, swapId: uint, fromToken: <ft-trait>, toToken: <ft-trait>, weightX: uint, weightY: uint, dx: uint, minDy: (optional uint)}))
) 
  (let
    (
      (batchInfo (unwrap! batch0 ERR_INVALID_BATCH))
      (dexType (get dexType batchInfo))
      (poolId (get poolId batchInfo))
      (swapId (get swapId batchInfo))
      (fromToken (get fromToken batchInfo))
      (toToken (get toToken batchInfo))
      (weightX (get weightX batchInfo))
      (weightY (get weightY batchInfo))
      (dx (get dx batchInfo))
      (minDy (get minDy batchInfo))
      ;; 0xAAAA 0xBBBB.dispatcher
      (dy (get dy (try! (contract-call? .dispatcher swap dexType poolId swapId fromToken toToken weightX weightY dx minDy))))
    )
    (asserts! (>= dy (default-to u0 minDy)) ERR_RETURN_AMOUNT_IS_NOT_ENOUGH)
    (ok {dx: dx, dy: dy})
  )

)
(define-private (handleJump2 
    (batch0 (optional {dexType: uint, poolId: uint, swapId: uint, fromToken: <ft-trait>, toToken: <ft-trait>, weightX: uint, weightY: uint, dx: uint, minDy: (optional uint)}))
    (batch1 (optional {dexType: uint, poolId: uint, swapId: uint, fromToken: <ft-trait>, toToken: <ft-trait>, weightX: uint, weightY: uint, dx: uint, minDy: (optional uint)}))
    (batch2 (optional {dexType: uint, poolId: uint, swapId: uint, fromToken: <ft-trait>, toToken: <ft-trait>, weightX: uint, weightY: uint, dx: uint, minDy: (optional uint)}))
) 
  (let
    (
      (batchInfo (unwrap! batch0 ERR_INVALID_BATCH))
      (dexType (get dexType batchInfo))
      (poolId (get poolId batchInfo))
      (swapId (get swapId batchInfo))
      (fromToken (get fromToken batchInfo))
      (toToken (get toToken batchInfo))
      (weightX (get weightX batchInfo))
      (weightY (get weightY batchInfo))
      (dx (get dx batchInfo))
      (minDy (get minDy batchInfo))
      ;; 0xAAAA 0xBBBB.dispatcher
      (dy (get dy (try! (contract-call? .dispatcher swap dexType poolId swapId fromToken toToken weightX weightY dx minDy))))
    )
    (asserts! (>= dy (default-to u0 minDy)) ERR_RETURN_AMOUNT_IS_NOT_ENOUGH)
    (ok {dx: dx, dy: dy})
  )

)