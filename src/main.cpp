#include "hardware.h"

bool SystemClock_Config() {
	RCC_OscInitTypeDef RCC_OscInitStruct = {0, 0, 0, 0, 0, 0, 0, {0, 0, 0}};
	RCC_ClkInitTypeDef RCC_ClkInitStruct = {0, 0, 0, 0, 0};
	// Initializes the CPU, AHB and APB busses clocks
	RCC_OscInitStruct.OscillatorType = RCC_OSCILLATORTYPE_HSE;
	RCC_OscInitStruct.HSEState = RCC_HSE_ON;                    //RCC_HSEConfig(RCC_HSE_ON); //Enable HSE
	RCC_OscInitStruct.HSEPredivValue =
			RCC_HSE_PREDIV_DIV1;        // RCC_PREDIV1Config(RCC_PREDIV1_Div1);//PREDIV 1 Divider = 1
	RCC_OscInitStruct.HSIState = RCC_HSI_ON;
	// RCC_OscInitStruct.LSIState = RCC_LSI_ON;
	RCC_OscInitStruct.PLL.PLLState = RCC_PLL_ON;                //RCC_PLLCmd(ENABLE);//Enable PLL
	RCC_OscInitStruct.PLL.PLLSource =
			RCC_PLLSOURCE_HSE;        // RCC_PLLConfig(RCC_PLLSource_PREDIV1, RCC_PLLMul_9); //Set PREDIV1 as source for PLL,And set PLLMUL=9
	RCC_OscInitStruct.PLL.PLLMUL = RCC_PLL_MUL9;

	if (HAL_RCC_OscConfig(&RCC_OscInitStruct) != HAL_OK) {
		return false;
	}

	// Initializes the CPU, AHB and APB busses clocks
	RCC_ClkInitStruct.ClockType = RCC_CLOCKTYPE_HCLK | RCC_CLOCKTYPE_SYSCLK
								  | RCC_CLOCKTYPE_PCLK1 | RCC_CLOCKTYPE_PCLK2;
	RCC_ClkInitStruct.SYSCLKSource = RCC_SYSCLKSOURCE_PLLCLK;
	RCC_ClkInitStruct.AHBCLKDivider = RCC_SYSCLK_DIV1;
	RCC_ClkInitStruct.APB1CLKDivider = RCC_HCLK_DIV2;
	RCC_ClkInitStruct.APB2CLKDivider = RCC_HCLK_DIV1;

	if (HAL_RCC_ClockConfig(&RCC_ClkInitStruct, FLASH_LATENCY_2) != HAL_OK) {
		return false;
	}

	//PeriphClkInit.PeriphClockSelection = RCC_PERIPHCLK_TIM1;
	//PeriphClkInit.Tim1ClockSelection = RCC_TIM1CLK_HCLK;
	RCC_PeriphCLKInitTypeDef PeriphClkInit = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};

	if (HAL_RCCEx_PeriphCLKConfig(&PeriphClkInit) != HAL_OK) {
		return false;
	}

	return true;
}

int main() {
	HAL_Init();
	SystemClock_Config();

	while (true) {
	}
}

