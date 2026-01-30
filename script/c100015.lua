--link 小美人鱼
function c100015.initial_effect(c)
	   --link summon
	aux.AddLinkProcedure(c,c100015.matfilter,1,1)

	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,100015)
	e1:SetCondition(c100015.spcon)
	e1:SetOperation(c100015.damop)
	c:RegisterEffect(e1)
	
	-- Effect 2: Life Points recovery
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(100015,1))
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,100015+1)
	e2:SetCost(aux.bfgcost)
	e2:SetOperation(c100015.recop)
	c:RegisterEffect(e2)
end

function c100015.matfilter(c)
	return c:IsLinkSetCard(0x208) and not c:IsLinkType(TYPE_LINK)
end


function c100015.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end

-- Operation for Effect 1: Damage becomes 0
function c100015.damop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	
	local e2=e1:Clone()
	e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	Duel.RegisterEffect(e2,tp)
end

-- Operation for Effect 2: Life Points recovery
function c100015.recop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,TYPE_SPELL)
	local rec=g:GetCount()*200
	Duel.Recover(tp,rec,REASON_EFFECT)
end
