#include "hardware.h"
#include <void/delay.h>

int main() {
	HAL_Init();
	cph::Clock::configure_as<cph::Clock::PllClock::External, 8000000>::Mhz_72();
	while (true) {
		vd::delay(1_s);
	}
}