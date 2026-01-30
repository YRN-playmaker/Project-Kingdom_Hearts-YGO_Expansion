-- Counter Trap: 键刃使 反击者 (c100067)
function c100067.initial_effect(c)
	-- Negate the activation and deal 800 damage
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DAMAGE+CATEGORY_TODECK+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c100067.condition)
	e1:SetTarget(c100067.target)
	e1:SetOperation(c100067.operation)
	e1:SetCountLimit(2,100067)
	c:RegisterEffect(e1)
end

-- Condition: Can activate if there is a "键刃使" card on your field and opponent activates a monster, spell, or trap card
function c100067.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_ONFIELD,0,1,nil,0x208)
		and re:IsActiveType(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP)
		and Duel.IsChainNegatable(ev)
		and rp==1-tp -- Opponent's activation
end

-- Target: Negate the activation, deal 800 damage, and handle chain conditions
function c100067.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,800)
end

-- Operation: Handle negate, damage, and additional chain effects
function c100067.operation(e,tp,eg,ep,ev,re,r,rp)
	-- Negate the activation and deal 800 damage
	if Duel.NegateActivation(ev) then
		Duel.Damage(1-tp,800,REASON_EFFECT)
	end

	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end -- Ensure the card is still related to the effect
	if Duel.SendtoGrave(c,REASON_EFFECT) ~= 0 then -- Send the card to the Graveyard
		local ct=Duel.GetCurrentChain() -- Get current chain count

		-- If chain count is 2 or 3, return the card from Graveyard to hand
		if  ct==3 then
			if c:IsLocation(LOCATION_GRAVE) then
				Duel.SendtoHand(c,nil,REASON_EFFECT)
			end

		-- If chain count is 4 or more, destroy the activated card and set this card from Graveyard face-down on the field
		elseif ct>=4 then
			if eg:GetFirst():IsRelateToEffect(re) then
				Duel.Destroy(eg,REASON_EFFECT)
			end
			if c:IsLocation(LOCATION_GRAVE) then
				Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEDOWN,true)
			end
		end
	end
end

