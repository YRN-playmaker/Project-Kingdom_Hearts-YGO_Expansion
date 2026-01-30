-- 键刃使 索拉Ultima from
function c100005.initial_effect(c)
	-- fusion material
	c:EnableReviveLimit()
	aux.AddFusionProcCodeFun(c,100000,aux.FilterBoolFunction(Card.IsFusionSetCard,0x208),4,true,true)

	-- summon condition
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(aux.fuslimit)
	c:RegisterEffect(e0)

	-- summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_DISABLE_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e1)

	-- summon success
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(100005,0))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_NO_TURN_RESET)
	e2:SetCondition(c100005.condition)
	e2:SetTarget(c100005.target)
	e2:SetOperation(c100005.operation)
	c:RegisterEffect(e2)

	-- indestructible in battle
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end

function c100005.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end

function c100005.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	Duel.SetChainLimit(aux.FALSE)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
end

function c100005.operation(e,tp,eg,ep,ev,re,r,rp)

	-- 禁止连锁直至链结束
	Duel.SetChainLimitTillChainEnd(aux.FALSE)
	local c=e:GetHandler()
	 -- 除外除自身以外所有场上的卡
	local g=Duel.GetMatchingGroup(function(tc) return tc~=c end, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, nil)
	Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
end
function c100005.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP+TYPE_MONSTER)
end
