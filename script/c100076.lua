--维恩图斯风格-翼刃
-- 指令动作-翼刃进击
function c100076.initial_effect(c)
	aux.AddCodeList(c,100066)
	c:EnableReviveLimit()
	--Cannot special summon
	local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(c100076.splimit)
	c:RegisterEffect(e0)

	-- 特殊召唤成功生成衍生物
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(100076,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,100076)
	e1:SetTarget(c100076.tktg)
	e1:SetOperation(c100076.tkop)
	c:RegisterEffect(e1)

	-- 破坏继续攻击
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(100076,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetCondition(aux.bdocon)
	e2:SetCost(c100076.atkcost)
	e2:SetOperation(c100076.atkop)
	c:RegisterEffect(e2)

	-- 不可被选为攻击与效果对象
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c100076.procon)
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e4:SetValue(1)
	c:RegisterEffect(e4)
end

function c100076.splimit(e,se,sp,st)
	local sc = se:GetHandler()
	return sc and sc:IsCode(100066)
end


-- 特召成功生成衍生物
function c100076.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,100050,0,TYPES_TOKEN,200,200,1,RACE_FAIRY,ATTRIBUTE_WIND) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function c100076.tkop(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	if Duel.IsPlayerCanSpecialSummonMonster(tp,100050,0,TYPES_TOKEN,200,200,1,RACE_FAIRY,ATTRIBUTE_WIND) then
		for i=1,ft do
			local token=Duel.CreateToken(tp,100050)
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UNRELEASABLE_SUM)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			token:RegisterEffect(e1)
		end
		Duel.SpecialSummonComplete()
	end
end

-- 送1衍生物 增加攻击 并可继续攻击
function c100076.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroup(tp,c100076.tkfilter,1,nil) end
	local g=Duel.SelectReleaseGroup(tp,c100076.tkfilter,1,1,nil)
	Duel.Release(g,REASON_COST)
end
function c100076.tkfilter(c)
	return c:IsCode(100050) and c:IsReleasable()
end
function c100076.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(200)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		Duel.ChainAttack()
	end
end

-- 有衍生物存在就保护
-- 保持原来写法，但稍作调整，确保无问题
function c100076.procon(e)
	return Duel.IsExistingMatchingCard(Card.IsCode,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil,100050)
end

