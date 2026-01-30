-- 永续陷阱卡 c100011
function c100011.initial_effect(c)
	-- 激活时触发效果
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(c100011.activate)
	c:RegisterEffect(e1)
	
	-- 每次准备阶段支付基本分或破坏
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c100011.paycon)
	e2:SetOperation(c100011.payop)
	c:RegisterEffect(e2)

	-- 魔法师族以外的攻击力高于1500的怪兽不能攻击
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE, LOCATION_MZONE)
	e3:SetCondition(c100011.atkcon)
	e3:SetTarget(c100011.atktg)
	c:RegisterEffect(e3)
end

-- 每次准备阶段支付基本分的效果条件
function c100011.paycon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end

-- 每次准备阶段支付基本分的效果操作
function c100011.payop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.CheckLPCost(tp,1000) and Duel.SelectYesNo(tp,aux.Stringid(100011,0)) then
		Duel.PayLPCost(tp,1000)
	else
		Duel.Destroy(e:GetHandler(),REASON_COST)
	end
end

-- 筛选非魔法师族怪兽
function c100011.filter(c)
	return not c:IsRace(RACE_SPELLCASTER) and c:IsFaceup()
end

-- ①：发动时，降低非魔法师族怪兽攻击力的效果操作
function c100011.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(c100011.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		local lv=tc:GetLevel() + tc:GetRank() + tc:GetLink()
		if lv > 0 then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(-lv * 200)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
		tc=g:GetNext()
	end
end

-- ②：魔法师族以外攻击力高于1500的怪兽不能攻击宣言的条件
function c100011.atkcon(e)
	return Duel.IsExistingMatchingCard(c100011.filter,e:GetHandlerPlayer(),LOCATION_MZONE,LOCATION_MZONE,1,nil)
end

-- ②：魔法师族以外攻击力高于1500的怪兽不能攻击宣言的效果目标
function c100011.atktg(e,c)
	return not c:IsRace(RACE_SPELLCASTER) and c:IsAttackAbove(1500)
end
