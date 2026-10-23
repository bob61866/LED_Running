/* ============================================================
 *  流水灯 + 按键换向（STM32F103C8T6 最小系统板）
 *  ------------------------------------------------------------
 *  LED1~LED4 : PA0 ~ PA3，推挽输出，高电平点亮
 *              接法：PAx -- 330Ω -- LED 长脚(+)，LED 短脚(-) -- GND
 *  按键 KEY  : PA4，内部上拉输入
 *              接法：PA4 -- 按键 -- GND（按下为低电平）
 *  功能      : 四个 LED 轮流点亮；按一下按键，流动方向反转
 * ============================================================ */
#include "stm32f10x.h"

#define LED_PORT    GPIOA
#define LED_ALL     (GPIO_Pin_0 | GPIO_Pin_1 | GPIO_Pin_2 | GPIO_Pin_3)
#define KEY_PORT    GPIOA
#define KEY_PIN     GPIO_Pin_4

#define LED_NUM     4
#define SPEED_MS    200     /* 每颗 LED 停留时间，单位 ms，可自行调整 */

/* 毫秒级延时（基于 SysTick） */
static void Delay_ms(uint32_t n)
{
    SysTick->LOAD = SystemCoreClock / 1000 - 1;
    SysTick->VAL  = 0;
    SysTick->CTRL = SysTick_CTRL_CLKSOURCE_Msk | SysTick_CTRL_ENABLE_Msk;
    while (n--)
    {
        while ((SysTick->CTRL & SysTick_CTRL_COUNTFLAG_Msk) == 0);
    }
    SysTick->CTRL = 0;
}

int main(void)
{
    GPIO_InitTypeDef gpio;
    uint8_t pos = 0;        /* 当前点亮的 LED 序号 0~3 */
    int8_t  dir = 1;        /* 1 = 从 LED1 往 LED4 流，-1 = 反向 */

    /* 1. 打开 GPIOA 时钟 */
    RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOA, ENABLE);

    /* 2. 四个 LED 引脚配置为推挽输出 */
    gpio.GPIO_Pin   = LED_ALL;
    gpio.GPIO_Mode  = GPIO_Mode_Out_PP;
    gpio.GPIO_Speed = GPIO_Speed_50MHz;
    GPIO_Init(LED_PORT, &gpio);

    /* 3. 按键引脚配置为上拉输入 */
    gpio.GPIO_Pin  = KEY_PIN;
    gpio.GPIO_Mode = GPIO_Mode_IPU;
    GPIO_Init(KEY_PORT, &gpio);

    GPIO_ResetBits(LED_PORT, LED_ALL);   /* 上电先全部熄灭 */

    while (1)
    {
        /* 4. 只点亮当前这一颗 */
        GPIO_ResetBits(LED_PORT, LED_ALL);
        GPIO_SetBits(LED_PORT, (uint16_t)(1U << pos));
        Delay_ms(SPEED_MS);

        /* 5. 按键检测：按下为低电平，做 20ms 消抖 */
        if (GPIO_ReadInputDataBit(KEY_PORT, KEY_PIN) == Bit_RESET)
        {
            Delay_ms(20);
            if (GPIO_ReadInputDataBit(KEY_PORT, KEY_PIN) == Bit_RESET)
            {
                dir = -dir;                       /* 换向 */
                while (GPIO_ReadInputDataBit(KEY_PORT, KEY_PIN) == Bit_RESET);
            }                                     /* 等待松手，防止连按 */
        }

        /* 6. 计算下一个位置 */
        if (dir > 0)
        {
            pos++;
            if (pos >= LED_NUM) pos = 0;
        }
        else
        {
            if (pos == 0) pos = LED_NUM - 1;
            else          pos--;
        }
    }
}
