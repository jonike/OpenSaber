#include "Grinliz_Util.h"
#include <math.h>

static int16_t gSinTable[256] = { 0 };

uint8_t lerpU8(uint8_t a, uint8_t b, uint8_t t) 
{
    int32_t r = int32_t(a) + (int32_t(b) - int32_t(a)) * int32_t(t) / 255;
    return uint8_t(clamp(r, int32_t(0), int32_t(255)));
}

bool TestUtil()
{
    //clamp()
    TEST_IS_EQ(clamp(-10, 0, 100), 0);
    TEST_IS_EQ(clamp(10,  0, 100), 10);
    TEST_IS_EQ(clamp(110, 0, 100), 100);

    // lerpU8()
	TEST_IS_EQ(lerpU8(0, 128, 128), 64);
	TEST_IS_EQ(lerpU8(0, 128, 0), 0);
	TEST_IS_EQ(lerpU8(0, 128, 255), 128);

	TEST_IS_EQ(lerpU8(0, 255, 128), 128);
	TEST_IS_EQ(lerpU8(0, 255, 0), 0);
	TEST_IS_EQ(lerpU8(0, 255, 255), 255);

	return true;
}

int16_t isin(uint16_t x)
{
	if (gSinTable[64] == 0) {
		for (int i = 0; i < 256; ++i) {
			float x = 2 * 3.14159f * float(i) / 256.0f;
			gSinTable[i] = int16_t(sin(x) * 256.0f);
		}
	}
	return gSinTable[x & 0xff];
}


bool strStarts(const char* str, const char* prefix)
{
    if (!str || !prefix)
        return false;

    while(*prefix) {
        if (*prefix++ != *str++)
            return false;
    }
    return true;
}

char ToLower(char c) {
    if (c >= 'A' && c <= 'Z')
        return (c - 'A') + 'a';
    return c;
}

bool istrStarts(const char* str, const char* prefix)
{
    if (!str || !prefix)
        return false;

    while(*prefix) {
        if (ToLower(*prefix++) != ToLower(*str++))
            return false;
    }
    return true;
}


bool TestCStr()
{
    TEST_IS_TRUE(strStarts("FooBar", "Foo"));
    TEST_IS_FALSE(strStarts("FooBar", "Bar"));
    TEST_IS_FALSE(strStarts("Foo", "FooBar"));
    TEST_IS_FALSE(strStarts(0, "Foo"));
    TEST_IS_FALSE(strStarts("Foo", 0));

    static const char* STR4 = "Four";
    static const char* STR8 = "ThisIs-8";
    static const char* STR9 = "ThisIs-8+";

    {
        CStr<9> s;
        TEST_IS_TRUE(s.empty());
        TEST_IS_TRUE(s == "");

        s = STR4;
        TEST_IS_TRUE(s[4] == 0);
        TEST_IS_TRUE(s.size() == 4);
        TEST_IS_FALSE(s.empty());
        TEST_IS_EQ(s.capacity(), 8);
        s.append("F");
        TEST_IS_TRUE(s == "FourF");
        s.append("ourF");
        TEST_IS_TRUE(s.size() == 8);
        TEST_IS_TRUE(s == "FourFour");
        TEST_IS_FALSE(s != "FourFour");
        TEST_IS_TRUE(s[8] == 0);
        TEST_IS_TRUE(s[0] == 'F');

        CStr<9> s2 = s;
        TEST_IS_TRUE(s == s2.c_str());
        s.clear();
        TEST_IS_TRUE(s.empty());
        TEST_IS_TRUE(s != s2.c_str());
    }
    {
        CStr<9> s = STR9;
        TEST_IS_TRUE(s == STR8);
        s += "TooLooong";
        TEST_IS_TRUE(s == STR8);
    }
    {
        CStr<9> s;
        s += STR4;
        TEST_IS_TRUE(s == STR4);
    }
    {
        CStr<5> s;
        s.append('F');
        s.append("our");
        TEST_IS_TRUE(s == "Four");
    }
	{
		static const uint32_t values[] = {
			0, 1, 12, 123,
			0, 1, 12, 123
		};
		static const bool zeroFill[] = {
			false, false, false, false,
			true, true, true, true
		};
		static const char* answer[] = {
			" 0", " 1", "12", "",
			"00", "01", "12", ""
		};

		for (int i = 0; i < 8; ++i) {
			CStr<3> s = "999";
			s.setFromNum(values[i], zeroFill[i]);
			TEST_IS_EQ(s, answer[i]);
		}
	}
    { 
        CStr<10> val("value");
        TEST_IS_TRUE(val.beginsWith("v"));
        TEST_IS_TRUE(val.beginsWith("val"));
        TEST_IS_TRUE(val.beginsWith("value"));
        TEST_IS_FALSE(val.beginsWith("al"));
        TEST_IS_FALSE(val.beginsWith("values"));
    }
	return true;
}


int hexToDec(char h) 
{
    if (h >= '0' && h <= '9') return h - '0';
    if (h >= 'a' && h <= 'f') return 10 + h - 'a';
    if (h >= 'A' && h <= 'F') return 10 + h - 'A';
    return 0;
}

char decToHex(int v) 
{
    if (v >= 0 && v < 10) return '0' + v;
    if (v>= 10 && v < 16) return 'a' + v - 10;
    return '0';
}

bool TestHexDec()
{
    TEST_IS_TRUE(hexToDec('A') == 10);
    TEST_IS_TRUE(hexToDec('F') == 15);
    TEST_IS_TRUE(hexToDec('a') == 10);
    TEST_IS_TRUE(hexToDec('f') == 15);
    TEST_IS_TRUE(hexToDec('0') == 0);
    TEST_IS_TRUE(hexToDec('9') == 9);
    TEST_IS_TRUE(hexToDec('G') == 0);
    TEST_IS_TRUE(hexToDec('#') == 0);

    TEST_IS_TRUE(decToHex(0) == '0');
    TEST_IS_TRUE(decToHex(9) == '9');
    TEST_IS_TRUE(decToHex(10) == 'a');
    TEST_IS_TRUE(decToHex(15) == 'f');
    TEST_IS_TRUE(decToHex(-1) == '0');
    TEST_IS_TRUE(decToHex(16) == '0');

    return true;
}


void parseHex(const CStr<7>& str, uint8_t* c)
{
    for (int i = 0; i < 3; ++i) {
        c[i] = hexToDec(str[i*2+0]) * 16 + hexToDec(str[i*2+1]);
    }
}

void parseHex(const CStr<4>& str, uint8_t* c)
{
    for (int i = 0; i < 3; ++i) {
        int h = hexToDec(str[i]);
        c[i] = h * 16 + h;
    }
}

void writeHex(const uint8_t* c, CStr<7>* str) 
{
    str->clear();
    for(int i=0; i<3; ++i) {
        str->append(decToHex(c[i] / 16));
        str->append(decToHex(c[i] & 15));
    }
}

bool TestHex()
{
	CStr<7> inLong("a1b2c3");
	CStr<4> inShort("abc");
	CStr<7> out;

	uint8_t rgb[3];

	parseHex(inLong, rgb);
	TEST_IS_TRUE(rgb[0] == 0xa1);
	TEST_IS_TRUE(rgb[1] == 0xb2);
	TEST_IS_TRUE(rgb[2] == 0xc3);

	parseHex(inShort, rgb);
	TEST_IS_TRUE(rgb[0] == 0xaa);
	TEST_IS_TRUE(rgb[1] == 0xbb);
	TEST_IS_TRUE(rgb[2] == 0xcc);

	writeHex(rgb, &out);
	TEST_IS_TRUE(out == "aabbcc");

	return true;
}

int Timer2::tick(uint32_t delta)
{
	int fires = 0;
	m_accum += delta;
	if (m_enable && delta && m_period && (m_accum >= m_period)) {
		fires = m_accum / m_period;
		if (m_repeating) {
			m_accum -= fires * m_period;
		}
		else {
			m_enable = false;
			fires = 1;
		}
	}
	return fires;
}

/*static*/ bool Timer2::Test()
{
	Timer2 t2;
	TEST_IS_EQ(t2.tick(900), 0);
	TEST_IS_EQ(t2.tick(100), 1);
	TEST_IS_EQ(t2.tick(2000), 2);

	t2.reset();
	t2.setRepeating(false);
	t2.setPeriod(500);
	TEST_IS_EQ(t2.tick(100), 0);
	TEST_IS_EQ(t2.tick(2000), 1);
	TEST_IS_FALSE(t2.enabled());
	TEST_IS_EQ(t2.tick(1200), 0);

	t2.setEnabled(true);
	TEST_IS_EQ(t2.tick(400), 0);
	TEST_IS_EQ(t2.tick(100), 1);
	TEST_IS_FALSE(t2.enabled());
	return true;
}

