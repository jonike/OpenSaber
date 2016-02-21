#ifndef SKETCHER_INCLUDED
#define SKETCHER_INCLUDED

#include <stdint.h>
#include "renderer.h"

class Sketcher
{
public:
	enum {
		WIDTH = 128,
		HEIGHT = 32,
		DATA_WIDTH = 52,
		DIAL_WIDTH = 28,
		INNERX = 38
	};

	void Draw(Renderer* d, uint32_t time, bool restMode);

	uint8_t power;
	uint8_t volume;
	uint8_t color[3];
	uint8_t data[DATA_WIDTH];

private:
	textureData GetDial(int value);

	uint8_t line = 0;
	uint32_t prevTime = 0;
	uint32_t animTime = 0;
};

#endif // SKETCHER_INCLUDED