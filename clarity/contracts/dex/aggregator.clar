

(use-trait ft-trait-arka .sip-010-trait-ft-standard.sip-010-trait)
(use-trait ft-trait-alex .trait-sip-010.sip-010-trait)

(use-trait dispatcherInterface .dispatcherTrait.DispatcherInterface)

(define-constant ONE_8 u100000000) ;; 8 decimal places
(define-data-var contract-owner principal tx-sender)

(define-constant ERR_BATCH_LENGTH (err u1001))
(define-constant ERR_INVALID_BATCH (err u1002))
(define-constant ERR_DISPATCH_FAILED (err u1003))
(define-constant ERR_RETURN_AMOUNT_IS_NOT_ENOUGH (err u1004))
(define-constant ERR_BALANCE_ERROR (err u1005))
(define-constant ERR_JUMP_FAILED (err u1006))
(define-constant ERR_NOT_OK (err u1007))
(define-constant ERR_NOT_AUTHORIZED (err u1008))




(define-public (unxswap 
    (baseRequest {fromToken: <ft-trait-arka>, toToken: <ft-trait-arka>, isNative: bool,fromTokenAmount: uint, minReturnAmount: uint}) 
    (batches (list 10 
      {adapterImpl: <dispatcherInterface>, 
      poolType: uint, 
      swapFuncType: uint, 
      fromToken: (optional <ft-trait-arka>), 
      toToken: (optional <ft-trait-arka>), 
      fromTokenAlex: (optional <ft-trait-alex>), 
      toTokenAlex: (optional <ft-trait-alex>), 
      weightX: uint, weightY: uint,factor: uint, dx: uint, minDy: (optional uint), rate: uint, isMul: bool}))
    )

    (let
      (
          (sender tx-sender)
          (isNative (get isNative baseRequest))
          (batchLen (len batches))
          (toToken (get toToken baseRequest))
          (fromTokenAmount (get fromTokenAmount baseRequest))
          (minReturnAmount (get minReturnAmount baseRequest))
          (fromToken (get fromToken baseRequest))
          
          (balanceBefore (getBalance toToken isNative sender))
          
          (dy (try! (fold handleJump batches (ok fromTokenAmount))))
      )

      ;; emit event: OrderRecord
      (print {orderRecord: {fromToken: fromToken, toToken: toToken, isNative: isNative, sender: sender, fromAmount: fromTokenAmount, returnAmount:  dy}})
      ;; return amount delta
      (checkMinReturn (getBalance toToken isNative sender) balanceBefore minReturnAmount)
    )


)

(define-private (getBalance (toToken <ft-trait-arka>) (isNative bool) (sender principal)) 
    (if isNative 
        (stx-get-balance sender)
        (match (contract-call? toToken get-balance sender) 
            amount amount
            err u0
        )
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
    (batch 
      {adapterImpl: <dispatcherInterface>, 
      poolType: uint, 
      swapFuncType: uint, 
      fromToken: (optional <ft-trait-arka>), 
      toToken: (optional <ft-trait-arka>), 
      fromTokenAlex: (optional <ft-trait-alex>), 
      toTokenAlex: (optional <ft-trait-alex>), 
      weightX: uint, 
      weightY: uint,
      factor: uint, 
      dx: uint, 
      minDy: (optional uint),
      rate: uint,
      isMul: bool}

    )
    (priorRes (response uint uint))
) 
(match priorRes
    amountIn 
    (let
        (
            (batchInfo (merge batch {dx: amountIn}))
            (adapterImpl (get adapterImpl batchInfo))
            (poolType (get poolType batchInfo))
            (swapFuncType (get swapFuncType batchInfo))
            (fromToken (get fromToken batchInfo))
            (toToken (get toToken batchInfo))
            (fromTokenAlex (get fromTokenAlex batchInfo))
            (toTokenAlex (get toTokenAlex batchInfo))
            (weightX (get weightX batchInfo))
            (weightY (get weightY batchInfo))
            (factor (get factor batchInfo))
            (dx (get dx batchInfo))
            (minDy (get minDy batchInfo))
            ;; (dy (if (and (is-some fromTokenAlex) (is-some toTokenAlex)) 
            ;;     (get dy (try! (contract-call? adapterImpl swapAlex poolType swapFuncType fromTokenAlex toTokenAlex weightX weightY factor dx minDy)))
            ;;     (if (and (is-some fromToken) (is-some toToken))
            ;;       (get dy (try! (contract-call? adapterImpl swapArki poolType swapFuncType fromToken toToken weightX weightY factor dx minDy)))
            ;;       u0
            ;;     )
            ;; )
            ;; 0xAAAA 0xBBBB.dispatcher
            (dy (get dy (try! (contract-call? adapterImpl swap
                    poolType swapFuncType fromToken toToken fromTokenAlex toTokenAlex weightX weightY factor dx minDy
                ))))
        )
        (asserts! (>= dy (default-to u0 minDy)) ERR_RETURN_AMOUNT_IS_NOT_ENOUGH)
        (ok dy)
    )
    err-value (err err-value)
)
 
)
