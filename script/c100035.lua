--键刃使 阿库娅
function c100035.initial_effect(c)
	c:EnableCounterPermit(0x3d1)
	c:SetCounterLimit(0x3d1,3)

	--① 特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(100035,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,100035)
	e1:SetCondition(c100035.spcon)
	e1:SetTarget(c100035.sptg)
	e1:SetOperation(c100035.spop)
	c:RegisterEffect(e1)

	--② 魔法卡发动→放置指示物
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c100035.ctcon)
	e2:SetOperation(c100035.ctop)
	c:RegisterEffect(e2)

	--③ 按照数量取除指示物发动不同效果
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(100035,1))
	e3:SetCategory(CATEGORY_EQUIP+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,100035+100)
	e3:SetTarget(c100035.thtg)
	e3:SetOperation(c100035.thop)
	c:RegisterEffect(e3)
end

--① 特召条件
function c100035.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(
		function(c) return c:IsType(TYPE_SPELL) and c:IsFaceup() end,
		tp, LOCATION_ONFIELD, 0, 1, nil)
end

function c100035.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c100035.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

--② 魔法卡发动放置指示物
function c100035.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_SPELL)
end
function c100035.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsOnField() then
		c:AddCounter(0x3d1,1)
	end
end

--③ 效果处理（不能选择，系统根据数量判断）
function c100035.eqfilter(c)
	return c:IsCode(100031) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
function c100035.thfilter(c)
	return (c:IsCode(100066) or c:IsCode(100013)) and c:IsAbleToHand()
end
function c100035.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=e:GetHandler():GetCounter(0x3d1)
	if chk==0 then
		return (ct>=2 and Duel.IsExistingMatchingCard(c100035.eqfilter,tp,LOCATION_DECK,0,1,nil))
			or (ct>=3 and Duel.IsExistingMatchingCard(c100035.thfilter,tp,LOCATION_DECK,0,1,nil))
	end
end
function c100035.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetCounter(0x3d1)

	local can_equip = ct >= 2 and Duel.IsExistingMatchingCard(c100035.eqfilter,tp,LOCATION_DECK,0,1,nil) and Duel.GetLocationCount(tp,LOCATION_SZONE) > 0
	local can_search = ct >= 3 and Duel.IsExistingMatchingCard(c100035.thfilter,tp,LOCATION_DECK,0,1,nil)

	if not can_equip and not can_search then return end

	local opt = 0
	if can_equip and can_search then
		opt = Duel.SelectOption(tp, aux.Stringid(100035,2), aux.Stringid(100035,3))  -- 0=装备, 1=检索
	elseif can_equip then
		Duel.Hint(HINT_CARD,0,100035)
		opt = 0
	else
		Duel.Hint(HINT_CARD,0,100035)
		opt = 1
	end

	if opt == 0 then
		-- 选择装备键刃使 米奇
		c:RemoveCounter(tp,0x3d1,2,REASON_COST)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		local g=Duel.SelectMatchingCard(tp,c100035.eqfilter,tp,LOCATION_DECK,0,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			if Duel.Equip(tp,tc,c) then
				-- 给装备卡赋予效果，使其当作装备
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_EQUIP_LIMIT)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				e1:SetValue(c100035.eqlimit)
				tc:RegisterEffect(e1)
			end
		end
	elseif opt == 1 then
		-- 选择检索 心之暗面 / 风格转换
		c:RemoveCounter(tp,0x3d1,3,REASON_COST)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,c100035.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g > 0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
end

-- 装备限制，只能装备到这张卡上
function c100035.eqlimit(e,c)
	return e:GetOwner()==c
end

