-- Custom Card Effect
function c100058.initial_effect(c)
	-- Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,100058+EFFECT_COUNT_CODE_DUEL)
	e1:SetTarget(c100058.target)
	e1:SetOperation(c100058.activate)
	c:RegisterEffect(e1)
end

function c100058.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
end

function c100058.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local max_discard=math.min(Duel.GetFieldGroupCount(tp,LOCATION_DECK,0),3)
	local ct=Duel.AnnounceNumber(tp,1,math.min(2,max_discard),max_discard)
	Duel.DiscardDeck(tp,ct,REASON_EFFECT)
	
	-- Apply effects based on the number of cards discarded
	if ct==1 then
		-- Skip opponent's next Draw Phase
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_SKIP_DP)
		e1:SetTargetRange(0,1)
		e1:SetReset(RESET_PHASE+PHASE_DRAW+RESET_OPPO_TURN)
		Duel.RegisterEffect(e1,tp)
	elseif ct==2 then
		-- Opponent's next turn starts from the Battle Phase
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetCode(EFFECT_SKIP_DP)
		e2:SetTargetRange(0,1)
		e2:SetReset(RESET_PHASE+PHASE_DRAW+RESET_OPPO_TURN)
		Duel.RegisterEffect(e2,tp)
		
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e3:SetCode(EFFECT_SKIP_M1)
		e3:SetTargetRange(0,1)
		e3:SetReset(RESET_PHASE+PHASE_MAIN1+RESET_OPPO_TURN)
		Duel.RegisterEffect(e3,tp)
	elseif ct==3 then
		-- Skip opponent's next turn
		local e4=Effect.CreateEffect(e:GetHandler())
		e4:SetType(EFFECT_TYPE_FIELD)
		e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e4:SetCode(EFFECT_SKIP_TURN)
		e4:SetTargetRange(0,1)
		e4:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		Duel.RegisterEffect(e4,tp)
		
		-- Restrict the player from activating Spell cards until the end of the opponent's next turn
		local e5=Effect.CreateEffect(e:GetHandler())
		e5:SetType(EFFECT_TYPE_FIELD)
		e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e5:SetCode(EFFECT_CANNOT_ACTIVATE)
		e5:SetTargetRange(1,0)
		e5:SetValue(c100058.aclimit)
		e5:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN)
		Duel.RegisterEffect(e5,tp)
	end

	-- Halve the damage the opponent takes
	local e6=Effect.CreateEffect(e:GetHandler())
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e6:SetCode(EFFECT_CHANGE_DAMAGE)
	e6:SetTargetRange(0,1)
	e6:SetValue(c100058.damval)
	e6:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
	Duel.RegisterEffect(e6,tp)
end

function c100058.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_SPELL)
end

function c100058.damval(e,re,val,r,rp,rc)
	if r&REASON_EFFECT~=0 then
		return val/2
	else
		return val
	end
end



