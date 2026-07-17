package cn.qihangerp.common.mq;

public class MqType {
    public static final int ORDER_MESSAGE = 1;
    public static final int REFUND_MESSAGE = 2;
    public static final int SHIP_STOCKUP_MESSAGE = 30;
    public static final int SHIP_SEND_MESSAGE = 40;

    public static final String ORDER_MQ = "ORDER_MQ";
    public static final String REFUND_MQ = "REFUND_MQ";
    public static final String SHIP_STOCK_UP_MQ = "SHIP_STOCK_UP_MQ";
    public static final String SHIP_SEND_MQ = "SHIP_SEND_MQ";
}
