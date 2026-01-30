-- 泰拉风格-暗黑冲动
-- ID: 100075
function c100075.initial_effect(c)
	-- 必须填写正确的卡名ID用于苏生限制检测
	aux.AddCodeList(c,100064)
	
	-- 苏生限制
	c:EnableReviveLimit()
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(c100075.splimit)
	c:RegisterEffect(e0)

	-- ①：压制效果 (不取对象，支付一半LP)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(100075,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,100075)
	e1:SetCondition(c100075.discon)
	e1:SetCost(c100075.discost)
	e1:SetTarget(c100075.distg)
	e1:SetOperation(c100075.disop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)

	-- ②：结束阶段翻卡 (仅限自己回合，必发)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(100075,1))
	e3:SetCategory(CATEGORY_DECKDES+CATEGORY_RECOVER+CATEGORY_TOGRAVE)
	-- 使用 TRIGGER_F (强制发动) 确保不会被卡时点
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F) 
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,100075+100)
	-- 增加条件检测：必须是自己回合
	e3:SetCondition(c100075.ef2con)
	e3:SetTarget(c100075.ef2tg)
	e3:SetOperation(c100075.ef2op)
	c:RegisterEffect(e3)
end

local CARD_STYLE_CHANGE = 100064

function c100075.splimit(e,se,sp,st)
	return se:GetHandler():IsCode(CARD_STYLE_CHANGE)
end

----------------------------------------------------------------
-- ① 压制逻辑
----------------------------------------------------------------
function c100075.discon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsControler,1,nil,1-tp)
end

function c100075.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end

function c100075.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(Card.IsControler,1,nil,1-tp) end
	Duel.SetChainLimit(c100075.chainlm)
end

function c100075.chainlm(e,rp,tp)
	return not (rp==1-tp and e:IsActiveType(TYPE_MONSTER))
end

function c100075.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=eg:Filter(Card.IsControler,nil,1-tp)
	for tc in aux.Next(g) do
		if tc:IsFaceup() and tc:IsLocation(LOCATION_MZONE) then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetValue(0)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_DISABLE_EFFECT)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e3)
		end
	end
end

----------------------------------------------------------------
-- ② 结束阶段翻卡
----------------------------------------------------------------
-- 条件：必须是自己的回合
function c100075.ef2con(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end

function c100075.ef2tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end

function c100075.ef2op(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0 then return end
	
	Duel.ConfirmDecktop(tp,1)
	local g=Duel.GetDecktopGroup(tp,1)
	local tc=g:GetFirst()
	
	if tc:IsType(TYPE_MONSTER) then
		local op=Duel.SelectOption(tp,aux.Stringid(100075,2),aux.Stringid(100075,3))
		if op==0 then
			Duel.MoveSequence(tc,SEQ_DECKBOTTOM)
			Duel.Recover(tp,1000,REASON_EFFECT)
		else
			Duel.DisableShuffleCheck()
			Duel.SendtoGrave(tc,REASON_EFFECT)
			Duel.SetLP(tp,Duel.GetLP(tp)-1000)
		end
	else
		Duel.MoveSequence(tc,SEQ_DECKTOP)
	end
end