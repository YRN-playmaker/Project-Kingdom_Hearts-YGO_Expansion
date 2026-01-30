-- 迪士尼 启程之地
function c100055.initial_effect(c)
	-- ①：发动时从卡组把1张「键刃使」加入手卡
	-- 【修复核心】这里去掉了 SetCountLimit，改为在 activate 函数内部手动检查 Flag
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(c100055.activate)
	c:RegisterEffect(e1)

	-- ②：从手卡把1只「键刃使」怪兽特殊召唤（1回合1次）
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(100055,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,100055)
	e2:SetTarget(c100055.sptg)
	e2:SetOperation(c100055.spop)
	c:RegisterEffect(e2)

	-- ③：召唤/特召成功的「键刃使」怪兽放置指示物
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(100055,2))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F) -- 强制发动
	e3:SetRange(LOCATION_FZONE)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetCondition(c100055.ctcon)
	e3:SetOperation(c100055.ctop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)

	-- ④：送墓时检索「忘却之城」（1回合1次）
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(100055,3))
	e5:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetCountLimit(1,100055+100)
	e5:SetCondition(c100055.thcon)
	e5:SetTarget(c100055.thtg)
	e5:SetOperation(c100055.thop)
	c:RegisterEffect(e5)
end

-- 指示物 ID
local COUNTER_ID = 0x3d1

----------------------------------------------------------------
-- ① 检索处理 (手动 Flag 限制)
----------------------------------------------------------------
function c100055.thfilter(c)
	return c:IsSetCard(0x208) and c:IsAbleToHand()
end

function c100055.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 1. 检查是否满足检索条件
	local g=Duel.GetMatchingGroup(c100055.thfilter,tp,LOCATION_DECK,0,nil)
	
	-- 2. 检查本回合是否已经用过这个检索效果 (通过 id 100055 来判断)
	-- 只有当 Flag 不存在(==0) 且 卡组有货 且 玩家选择“是” 时，才执行检索
	if #g>0 and Duel.GetFlagEffect(tp, 100055)==0 and Duel.SelectYesNo(tp,aux.Stringid(100055,0)) then
		-- 3. 注册“已使用”标记 (效果结算时注册，代替 OATH)
		Duel.RegisterFlagEffect(tp, 100055, RESET_PHASE+PHASE_END, 0, 1)
		
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
	-- 即使玩家选择“否”或者不能检索，卡片依然会成功发动并留在场地区域，不会变成盖卡。
end

----------------------------------------------------------------
-- ② 手卡特招
----------------------------------------------------------------
function c100055.spfilter(c,e,tp)
	return c:IsSetCard(0x208) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c100055.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c100055.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function c100055.spop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c100055.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

----------------------------------------------------------------
-- ③ 放置指示物
----------------------------------------------------------------
function c100055.ctfilter(c,tp)
	if not (c:IsFaceup() and c:IsControler(tp) and c:IsSetCard(0x208)) then return false end
	if not c:IsCanAddCounter(COUNTER_ID,1) then return false end
	-- 检查同名卡是否已放过 (100055 + 卡号 作为唯一Flag)
	local code = c:GetCode()
	return Duel.GetFlagEffect(tp, 100055+code) == 0
end

function c100055.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c100055.ctfilter,1,nil,tp)
end

function c100055.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	
	for tc in aux.Next(eg) do
		if c100055.ctfilter(tc,tp) then
			tc:AddCounter(COUNTER_ID,1)
			-- 注册标记，防止同名卡再次放置
			Duel.RegisterFlagEffect(tp, 100055+tc:GetCode(), RESET_PHASE+PHASE_END, 0, 1)
		end
	end
end

----------------------------------------------------------------
-- ④ 送墓检索
----------------------------------------------------------------
function c100055.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_FZONE) and c:IsPreviousPosition(POS_FACEUP)
end
function c100055.tgfilter(c)
	return c:IsCode(100056) and c:IsAbleToHand()
end
function c100055.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c100055.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c100055.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c100055.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end