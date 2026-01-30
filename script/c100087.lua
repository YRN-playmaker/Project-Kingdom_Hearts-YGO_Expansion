--卡片密码 100087
function c100087.initial_effect(c)
	--发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)

	--效果①：回收墓地 (场上「键刃使」离场触发)
	--条件：以自己墓地1只「键刃」装备魔法卡或者1张「指令」卡为对象
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(100087,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_LEAVE_FIELD)
	e1:SetRange(LOCATION_FZONE)
	e1:SetCountLimit(1,100087)
	e1:SetCondition(c100087.thcon1)
	e1:SetTarget(c100087.thtg1)
	e1:SetOperation(c100087.thop1)
	c:RegisterEffect(e1)

	--效果②：墓地除外检索 (送墓回合不能发动)
	--效果：从自己墓地中选1只「键刃使」怪兽加入手卡
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(100087,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,100088)
	e2:SetCondition(c100087.thcon2)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c100087.thtg2)
	e2:SetOperation(c100087.thop2)
	c:RegisterEffect(e2)
end

--字段定义
local SETCODE_WIELDER = 0x208 -- 键刃使
local SETCODE_KEYBLADE = 0x210 -- 键刃
local SETCODE_COMMAND = 0x20a  -- 指令 (请根据实际情况修改此代码)

-- ①效果：检测「键刃使」离开场上
function c100087.cfilter(c,tp)
	return c:IsSetCard(SETCODE_WIELDER) and c:IsType(TYPE_MONSTER)
		and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
end

function c100087.thcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c100087.cfilter,1,nil,tp)
end

-- ①效果：筛选「键刃」装备魔法 或 「指令」卡
function c100087.filter1(c)
	-- 选项A：「键刃」且是装备魔法
	local b1 = c:IsSetCard(SETCODE_KEYBLADE) and c:IsType(TYPE_EQUIP)
	-- 选项B：「指令」卡 (不限种类)
	local b2 = c:IsSetCard(SETCODE_COMMAND)
	return (b1 or b2) and c:IsAbleToHand()
end

function c100087.thtg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c100087.filter1(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c100087.filter1,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,c100087.filter1,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end

function c100087.thop1(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end

-- ②效果：检测是否为送去墓地的回合
function c100087.thcon2(e,tp,eg,ep,ev,re,r,rp)
	return aux.exccon(e) and e:GetHandler():GetTurnID() ~= Duel.GetTurnCount()
end

-- ②效果：筛选墓地「键刃使」怪兽
function c100087.filter2(c)
	return c:IsSetCard(SETCODE_WIELDER) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end

function c100087.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c100087.filter2,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end

function c100087.thop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c100087.filter2,tp,LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end