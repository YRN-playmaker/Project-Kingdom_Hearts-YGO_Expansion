--呼唤光之心
function c100007.initial_effect(c)
	 --Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c100007.condition)
	e1:SetTarget(c100007.target)
	e1:SetOperation(c100007.activate)
	c:RegisterEffect(e1)
end
function c100007.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker():IsControler(1-tp) and Duel.GetAttackTarget()==nil
end
function c100007.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function c100007.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateAttack() and Duel.Draw(tp,1,REASON_EFFECT)~=0 then
		local tc=Duel.GetOperatedGroup():GetFirst()
		if tc:IsType(TYPE_MONSTER) and tc:IsSummonable(true,nil)
			and Duel.SelectYesNo(tp,aux.Stringid(100007,0)) then
			Duel.BreakEffect()
			Duel.Summon(tp,tc,true,nil)
		
		
		elseif tc:IsCode(100007) and tc:IsSSetable()
			and Duel.SelectYesNo(tp,aux.Stringid(100007,0)) then
			Duel.BreakEffect()
			Duel.SSet(tp,tc)
		end
	end
end
	 
