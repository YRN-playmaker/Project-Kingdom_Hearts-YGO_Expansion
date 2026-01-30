-- 速攻魔法卡 c100063
function c100063.initial_effect(c)
	-- Activate
	local e1 = Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1, 100063 + EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c100063.condition)
	e1:SetTarget(c100063.target)
	e1:SetOperation(c100063.activate)
	c:RegisterEffect(e1)
end

function c100063.condition(e, tp, eg, ep, ev, re, r, rp)
	-- 检查自己场上是否有「键刃使」或[迪士尼]怪兽
	return Duel.IsExistingMatchingCard(c100063.filter, tp, LOCATION_MZONE, 0, 1, nil)
end

function c100063.filter(c)
	return c:IsFaceup() and (c:IsSetCard(0x208) or c:IsSetCard(0x209))
end

function c100063.target(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	if chk == 0 then return Duel.IsExistingTarget(Card.IsFaceup, tp, 0, LOCATION_MZONE, 1, nil) end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
	local g = Duel.SelectTarget(tp, Card.IsFaceup, tp, 0, LOCATION_MZONE, 1, 1, nil)
	Duel.SetOperationInfo(0, CATEGORY_REMOVE, g, 1, 0, 0)
end

function c100063.activate(e, tp, eg, ep, ev, re, r, rp)
	local tc = Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 除外目标怪兽
		Duel.Remove(tc, POS_FACEUP, REASON_EFFECT)
		
		-- 添加效果直到回合结束
		local e1 = Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetTargetRange(LOCATION_ONFIELD, LOCATION_ONFIELD)
		e1:SetTarget(c100063.distg)
		e1:SetLabelObject(tc)
		e1:SetReset(RESET_PHASE + PHASE_END)
		Duel.RegisterEffect(e1, tp)

		local e2 = e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		Duel.RegisterEffect(e2, tp)

		local e3 = Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
		e3:SetTargetRange(LOCATION_MZONE, LOCATION_MZONE)
		e3:SetTarget(c100063.distg)
		e3:SetLabelObject(tc)
		e3:SetReset(RESET_PHASE + PHASE_END)
		Duel.RegisterEffect(e3, tp)
		
		-- 禁用除外卡的效果
		local e4 = Effect.CreateEffect(e:GetHandler())
		e4:SetType(EFFECT_TYPE_FIELD)
		e4:SetCode(EFFECT_DISABLE)
		e4:SetTargetRange(LOCATION_ONFIELD, LOCATION_ONFIELD)
		e4:SetTarget(c100063.distg)
		e4:SetLabelObject(tc)
		e4:SetReset(RESET_PHASE + PHASE_END)
		Duel.RegisterEffect(e4, tp)
		
		local e5 = e4:Clone()
		e5:SetCode(EFFECT_DISABLE_EFFECT)
		Duel.RegisterEffect(e5, tp)
	end
end

function c100063.distg(e, c)
	local tc = e:GetLabelObject()
	return c:IsOriginalCodeRule(tc:GetOriginalCodeRule())
end

