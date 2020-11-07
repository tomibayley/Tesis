/* FILTROS:

            Pasa-Bajo 250
            Pasa-Banda 250-1000
            Pasa-Banda 1000-6000
            Pasa-Alto 6000
*/


//#include <wirish/wirish.h>
//#include "libraries/FreeRTOS/MapleFreeRTOS.h"

#include <SPI.h>
#include <URTouch.h>
#include <Adafruit_ILI9341.h>

#include <MapleFreeRTOS900.h>
#define BOARD_LED_PIN PC13
#define dif 60


//COLORES

#define ColorBoton 0xFEA0
#define Colorsigno 0x0000
#define ColorTexto 0xFFFF
#define ColorBarra 0x6B51
#define ColorSelector 0xC63B
#define ColorFondo 0x106B
#define ColorPuntos 0x18C3


//#define pinV PA1
//#define pinG PA9
//#define pinM PA8
//#define pinA PB9
//#define pinMA PA0

//#define PWMA PA0
#define PWMB PA10

// PINES DISPLAY
#define TFT_DC PB0
#define TFT_CS PB10
#define TFT_RST PB1


// TFT_MOSI--> PA7
// TFT_MISO--> PA6
// TFT_CLK--> PA5

//PA3-->TX    PA2 -->RX BLUETOOTH

//Pines Touch
#define t_SCK  PB14
#define t_CS   PB5
#define t_MOSI PB6
#define t_MISO PB7
#define t_IRQ  PB8

//Pines AD5206

#define slaveSelectPin PB9

//Instanciamos la TFT
Adafruit_ILI9341 tft = Adafruit_ILI9341(TFT_CS, TFT_DC, TFT_RST);

//Instancimos el Touch
URTouch ts(t_SCK, t_CS, t_MOSI, t_MISO, t_IRQ);
float valor = 0;
int op = 1000, vol = 5, ag = 10, me = 10, gr = 10, meag = 10;
float volflo = 5.0;
char p = 1000;
int x, y;
int oldvol = 10, oldme = 10, oldmeag = 10, oldag = 10, oldgr = 10;
int h = 1000;

void setup() {
  SETUP();
  Serial.begin(9600);



  xTaskCreate(vLEDFlashTask,
              "Task1",
              128,
              NULL,
              tskIDLE_PRIORITY + 15,
              NULL);

  xTaskCreate(touchtask,
              "Task2",
              256,
              NULL,
              tskIDLE_PRIORITY + 8,
              NULL);


  xTaskCreate(salidastask,
              "Task3",
              128,
              NULL,
              tskIDLE_PRIORITY + 11,
              NULL);

  xTaskCreate(blututask,
              "Task3",
              128,
              NULL,
              tskIDLE_PRIORITY + 9,
              NULL);
  /*
    xTaskCreate(pwmtask,
                "Task4",
                128,
                NULL,
                tskIDLE_PRIORITY + 1,
                NULL);
  */
  vTaskStartScheduler();
}

void loop() {
  // Insert background code here
}



void SETUP() {
  /*************Confguracion de la TFT*************/

  tft.begin();
  tft.setRotation(3);
  tft.setTextColor(ILI9341_BLUE);
  tft.setTextSize(3);
  tft.setCursor(35, 25);
  tft.fillScreen(ILI9341_BLACK);
  tft.println("PROYECTO FINAL");
  tft.println("     UTN-FRC \n   ELECTRONICA");
  tft.setTextColor(ILI9341_RED);
  tft.setTextSize(2);
  tft.setCursor(85, 150);
  tft.print("Arias-Bayley\n      Camoletto-Mongi");
  SPI.begin();
  delay(1000); //3segundos
  
  //PINRELE ON


  /********Configuracion del Touch*********/

  ts.InitTouch();
  ts.setPrecision(PREC_MEDIUM);


  /****************************Puertos y BT***************************/

  Serial2.begin(9600);    //Puerto Módulo BT
  /*pinMode(pinV, PWM);
    pinMode(pinG, PWM);
    pinMode(pinM, PWM);
    pinMode(pinA, PWM);
    pinMode(pinMA, PWM);*/
  pinMode(slaveSelectPin, OUTPUT);

  //pinMode(PWMA, OUTPUT);
  //pinMode(PWMB, OUTPUT);

  pinMode(BOARD_LED_PIN, OUTPUT);
  /*****************/
  InterfazConBarra();
}


void InterfazConBarra()
{
  /********Generales y fondo*********/

  tft.fillScreen(ColorFondo); //Fondo
  tft.setTextColor(ColorTexto);
  //tft.setFont(LiberationMono_24_Bold);
  tft.setTextColor(ColorTexto);
  tft.setTextSize(2);


  tft.setCursor(25, 200);
  tft.print("VOL");
  tft.setCursor(25 + dif, 200);
  tft.print("LOW");
  tft.setCursor(25 + 2 * dif, 200);
  tft.print("MED");
  tft.setCursor(30 + 3 * dif, 200);
  tft.print("MH");
  tft.setCursor(25 + 4 * dif, 200);
  tft.print("HIGH");


  tft.setCursor(36, 10);
  tft.print(vol);

  tft.setCursor(36 + dif, 10);
  tft.print(ag);

  tft.setCursor(36 + 2 * dif, 10);
  //tft.print("Medios: ");
  tft.print(me);

  tft.setCursor(36 + 3 * dif, 10);
  tft.print(gr);

  tft.setCursor(36 + 4 * dif, 10);
  tft.print(meag);



  /*******Lineas de Sliders Verticales**********/

  tft.drawFastVLine(40, 30, 160, ColorBarra);
  tft.drawFastVLine(40 + dif, 30, 160, ColorBarra);
  tft.drawFastVLine(40 + 2 * dif, 30, 160, ColorBarra);
  tft.drawFastVLine(40 + 3 * dif, 30, 160, ColorBarra);
  tft.drawFastVLine(40 + 4 * dif, 30, 160, ColorBarra);

  tft.drawFastVLine(41, 30, 160, ColorBarra);
  tft.drawFastVLine(41 + dif, 30, 160, ColorBarra);
  tft.drawFastVLine(41 + 2 * dif, 30, 160, ColorBarra);
  tft.drawFastVLine(41 + 3 * dif, 30, 160, ColorBarra);
  tft.drawFastVLine(41 + 4 * dif, 30, 160, ColorBarra);

  tft.drawFastVLine(42, 30, 160, ColorBarra);
  tft.drawFastVLine(42 + dif, 30, 160, ColorBarra);
  tft.drawFastVLine(42 + 2 * dif, 30, 160, ColorBarra);
  tft.drawFastVLine(42 + 3 * dif, 30, 160, ColorBarra);
  tft.drawFastVLine(42 + 4 * dif, 30, 160, ColorBarra);

  /********Puntos divisores*********/

  for (int i = 0; i < 11; i++)
  {
    tft.fillCircle( 41, (map(i, 0, 10, 30, 190) + 2), 2, ColorPuntos);
    tft.fillCircle( 41 + dif, (map(i, 0, 10, 30, 190) + 2), 2, ColorPuntos);
    tft.fillCircle( 41 + 2 * dif, (map(i, 0, 10, 30, 190) + 2), 2, ColorPuntos);
    tft.fillCircle( 41 + 3 * dif, (map(i, 0, 10, 30, 190) + 2), 2, ColorPuntos);
    tft.fillCircle( 41 + 4 * dif, (map(i, 0, 10, 30, 190) + 2), 2, ColorPuntos);
  }

  /*********Selectores********/

  tft.fillRoundRect(31, map(vol, 0, 10, 190, 30), 20, 5, 20, ColorSelector);
  tft.fillRoundRect(31 + dif, map(gr, 0, 10, 190, 30), 20, 5, 20, ColorSelector);
  tft.fillRoundRect(31 + 2 * dif, map(me, 0, 10, 190, 30), 20, 5, 20, ColorSelector);
  tft.fillRoundRect(31 + 3 * dif, map(meag, 0, 10, 190, 30), 20, 5, 20, ColorSelector);
  tft.fillRoundRect(31 + 4 * dif, map(ag, 0, 10, 190, 30), 20, 5, 20, ColorSelector);;
}

void MoverSlider(int x, int y) {
  if (y > 30 && y < 200) {
    // Vol
    if (x > 20 && x < 60) {
      // Map vol
      oldvol = vol;
      vol = map(y, 30, 190, 10, 0);
      //Serial.println(vol);
      if (y <= 40) {
        vol = 10;
      } else if (y >= 185) {
        vol = 0;
      }

      /*********Borrar el selector viejo; Volver a dibujar el punto divisor; Dibujar el nuevo selector********/

      tft.fillRoundRect(31, map(oldvol, 10, 0, 30, 190), 20, 5, 20, ColorFondo);
      tft.fillCircle( 41, (map(oldvol, 10, 0, 30, 190) + 2), 2, ColorPuntos);
      tft.fillRoundRect(31, map(vol, 10, 0, 30, 190), 20, 5, 20, ColorSelector);

      /********Actualizamos el número de la variable que cambió*********/

      tft.fillRect(36, 10, 27, 20, ColorFondo);
      tft.setCursor(36, 10);
      tft.print(vol);
    } else if (x > 20 + dif && x < 60 + dif) {
      // Map gr
      oldgr = gr;
      gr = map(y, 30, 190, 10, 0);
      if (y >= 185) {
        gr = 0;
      } else if (y <= 40) {
        gr = 10;
      }

      /*********Borrar el selector viejo; Volver a dibujar el punto divisor; Dibujar el nuevo selector********/

      tft.fillRoundRect(31 + dif, map(oldgr, 10, 0, 30, 190), 20, 5, 20, ColorFondo);
      tft.fillCircle( 41 + dif, (map(oldgr, 10, 0, 30, 190) + 2), 2, ColorPuntos);
      tft.fillRoundRect(31 + dif, map(gr, 10, 0, 30, 190), 20, 5, 20, ColorSelector);

      /********Actualizamos el número de la variable que cambió*********/

      tft.fillRect(36 + dif, 10, 27, 20, ColorFondo);
      tft.setCursor(36 + dif, 10);
      tft.print(gr);
    } else if (x > 20 + 2 * dif && x < 60 + 2 * dif) {
      // Map me
      oldme = me;
      me = map(y, 30, 190, 10, 0);
      if (y >= 185) {
        me = 0;
      } else if (y <= 40) {
        me = 10;
      }

      // Black out the old slider, re-draw the verticle bar, then draw the new slider
      tft.fillRoundRect(31 + 2 * dif, map(oldme, 10, 0, 30, 190), 20, 5, 20, ColorFondo);
      tft.fillCircle( 41 + 2 * dif, (map(oldme, 10, 0, 30, 190) + 2), 2, ColorPuntos);
      tft.fillRoundRect(31 + 2 * dif, map(me, 10, 0, 30, 190), 20, 5, 20, ColorSelector);

      /********Actualizamos el número de la variable que cambió*********/
      tft.fillRect(36 + 2 * dif, 10, 27, 20, ColorFondo);
      tft.setCursor(36 + 2 * dif, 10);
      tft.print(me);
    } else if (x > 20 + 4 * dif && x < 60 + 4 * dif) {
      // Map ag
      oldag = ag;
      ag = map(y, 30, 190, 10, 0);
      if (y >= 185) {
        ag = 0;
      } else if (y <= 40) {
        ag = 10;
      }

      /*********Borrar el selector viejo; Volver a dibujar el punto divisor; Dibujar el nuevo selector********/

      tft.fillRoundRect(31 + 4 * dif, map(oldag, 10, 0, 30, 190), 20, 5, 20, ColorFondo);
      tft.fillCircle( 41 + 4 * dif, (map(oldag, 10, 0, 30, 190) + 2), 2, ColorPuntos);
      tft.fillRoundRect(31 + 4 * dif, map(ag, 10, 0, 30, 190), 20, 5, 20, ColorSelector);

      /********Actualizamos el número de la variable que cambió*********/

      tft.fillRect(36 + 4 * dif, 10, 27, 20, ColorFondo);
      tft.setCursor(36 + 4 * dif, 10);
      tft.print(ag);
    }
    else if (x > 20 + 3 * dif && x < 60 + 3 * dif) {
      // Map meag
      oldmeag = meag;
      meag = map(y, 30, 190, 10, 0);
      if (y >= 185) {
        meag = 0;
      } else if (y <= 40) {
        meag = 10;
      }

      /*********Borrar el selector viejo; Volver a dibujar el punto divisor; Dibujar el nuevo selector********/

      tft.fillRoundRect(31 + 3 * dif, map(oldmeag, 10, 0, 30, 190), 20, 5, 20, ColorFondo);
      tft.fillCircle( 41 + 3 * dif, (map(oldmeag, 10, 0, 30, 190) + 2), 2, ColorPuntos);
      tft.fillRoundRect(31 + 3 * dif, map(meag, 10, 0, 30, 190), 20, 5, 20, ColorSelector);

      /********Actualizamos el número de la variable que cambió*********/

      tft.fillRect(36 + 3 * dif, 10, 27, 20, ColorFondo);
      tft.setCursor(36 + 3 * dif, 10);
      tft.print(meag);
    }
  }
  return;
}

void ActualizarSliderV() {

  /*********Borrar el selector viejo; Volver a dibujar el punto divisor; Dibujar el nuevo selector********/

  tft.fillRoundRect(31, map(oldvol, 10, 0, 30, 190), 20, 5, 20, ColorFondo);
  tft.fillCircle( 41, (map(oldvol, 10, 0, 30, 190) + 2), 2, ColorPuntos);
  tft.fillRoundRect(31, map(vol, 10, 0, 30, 190), 20, 5, 20, ColorSelector);

  /********Actualizamos el número de la variable que cambió*********/

  tft.fillRect(36, 10, 27, 20, ColorFondo);
  tft.setCursor(36, 10);
  tft.print(vol);


}
void ActualizarSliderA() {
  /*********Borrar el selector viejo; Volver a dibujar el punto divisor; Dibujar el nuevo selector********/
  tft.fillRoundRect(31 + 4 * dif, map(oldag, 10, 0, 30, 190), 20, 5, 20, ColorFondo);
  tft.fillCircle( 41 + 4 * dif, (map(oldag, 10, 0, 30, 190) + 2), 2, ColorPuntos);
  tft.fillRoundRect(31 + 4 * dif, map(ag, 10, 0, 30, 190), 20, 5, 20, ColorSelector);

  /********Actualizamos el número de la variable que cambió*********/

  tft.fillRect(36 + 4 * dif, 10, 27, 20, ColorFondo);
  tft.setCursor(36 + 4 * dif, 10);
  tft.print(ag);
  return;

}

void ActualizarSliderM() {
  // Black out the old slider, re-draw the verticle bar, then draw the new slider
  tft.fillRoundRect(31 + 2 * dif, map(oldme, 10, 0, 30, 190), 20, 5, 20, ColorFondo);
  tft.fillCircle( 41 + 2 * dif, (map(oldme, 10, 0, 30, 190) + 2), 2, ColorPuntos);
  tft.fillRoundRect(31 + 2 * dif, map(me, 10, 0, 30, 190), 20, 5, 20, ColorSelector);

  /********Actualizamos el número de la variable que cambió*********/
  tft.fillRect(36 + 2 * dif, 10, 27, 20, ColorFondo);
  tft.setCursor(36 + 2 * dif, 10);
  tft.print(me);
  return;

}
void ActualizarSliderG() {
  tft.fillRoundRect(31 + 1 * dif, map(oldgr, 10, 0, 30, 190), 20, 5, 20, ColorFondo);
  tft.fillCircle( 41 + 1 * dif, (map(oldgr, 10, 0, 30, 190) + 2), 2, ColorPuntos);
  tft.fillRoundRect(31 + 1 * dif, map(gr, 10, 0, 30, 190), 20, 5, 20, ColorSelector);

  /********Actualizamos el número de la variable que cambió*********/

  tft.fillRect(36 + 1 * dif, 10, 27, 20, ColorFondo);
  tft.setCursor(36 + 1 * dif, 10);
  tft.print(gr);
  return;
}

void ActualizarSliderMEAG() {

  /*********Borrar el selector viejo; Volver a dibujar el punto divisor; Dibujar el nuevo selector********/

  tft.fillRoundRect(31 + 3 * dif, map(oldmeag, 10, 0, 30, 190), 20, 5, 20, ColorFondo);
  tft.fillCircle( 41 + 3 * dif, (map(oldmeag, 10, 0, 30, 190) + 2), 2, ColorPuntos);
  tft.fillRoundRect(31 + 3 * dif, map(meag, 10, 0, 30, 190), 20, 5, 20, ColorSelector);

  /********Actualizamos el número de la variable que cambió*********/

  tft.fillRect(36 + 3 * dif, 10, 27, 20, ColorFondo);
  tft.setCursor(36 + 3 * dif, 10);
  tft.print(meag);
}


/*********Enviar a la app los valores para que se actualice********/

void Retorno()
{
  Serial2.write((vol + 48));
  Serial2.write((gr + 59));
  Serial2.write((me + 70));
  Serial2.write((meag + 94));
  Serial2.write((ag + 81));
  //Serial.print("\nVOL:");
  //Serial.write((vol + 48));
  //Serial.print("\nAG:");
  //Serial.write((ag + 59));
  //Serial.print("\nME:");
  //Serial.write((me + 70));
  //Serial.print("\nGR:");
  //Serial.write((gr + 81));

  return;
}


static void vLEDFlashTask(void *pvParameters) {
  for (;;) {
    vTaskDelay(1000);
    digitalWrite(BOARD_LED_PIN, HIGH);
    vTaskDelay(1000);
    digitalWrite(BOARD_LED_PIN, LOW);
    Serial2.flush();
  }
}


static void touchtask(void *pvParameters) {
  while (1) {
    if (ts.dataAvailable())    //Leer donde se pulsó el táctil
    {
      ts.read();
      x = ts.getX() ;
      y = ts.getY() ;
      x = x ;
      y = y + 5;
      MoverSlider(x, y);
      /* Serial.println("TOUCH:");
         Serial.println(x);
         Serial.println(y);
         delay(1000);*/
      Retorno();
      //Salidas();
      /* digitalWrite(PC13, HIGH);
        delay(200);
        Serial.println(x);
        digitalWrite(PC13, LOW);
        delay(200);
        Serial.println(y);

        if ((x != -1) && (y != -1))
        {
         int radius = 1;
         tft.fillCircle(x, y, radius, ILI9341_RED);
         //delay(40);
        }*/
    }
    vTaskDelay(75);
  }
}


static void blututask(void *pvParameters) {
  vTaskDelay(3000);
  while (1)
  { op = 1000;

    if (Serial2.available() > 0) {
      p = Serial2.read();
      op = p - 48;
      Serial.println(op);

      /********++Actualización de valores***********/

      if (op >= 0 && op < 11)           //Volumen
      {
        oldvol = vol;
        vol = op;
        if (oldvol != vol)
        {
          Serial2.write(vol);
          ActualizarSliderV();
        }
      } else if (op > 10 && op < 22)         //Graves
      {
        oldgr = gr;
        gr = op - 11;
        if (oldgr != gr)
        {
          Serial2.write(gr);
          ActualizarSliderG();
        }
      } else if (op > 21 && op < 33)         //Medios
      {
        oldme = me;
        me = op - 22;
        if (oldme != me)
        {
          Serial2.write(me);
          ActualizarSliderM();
        }
      } else if (op > 32 && op < 44)       //Agudos
      {
        oldag = ag;
        ag = op - 33;
        if (oldag != ag)
        {
          Serial2.write(ag);
          ActualizarSliderA();
        }
      }  else if (op > 44 && op < 56)       //MEDIOSAGUDOS
      {
        oldmeag = meag;
        meag = op - 45;
        if (oldmeag != meag)
        {
          Serial2.write(meag);
          ActualizarSliderMEAG();
        }
      } else if (op == 61)     //m MUTE
      { oldvol = vol;
        vol = 0;
        ActualizarSliderV();
      } else if (op == 58)   //JAZZ
      {
        Serial2.write(vol);
        oldgr = gr;
        oldvol = vol;
        oldag = ag;
        oldme = me;

        ag = 5;
        me = 5;
        gr = 5;
        ActualizarSliderA();
        ActualizarSliderG();
        ActualizarSliderM();
      } else  if (op == 66)   //ROCK
      {
        oldgr = gr;
        oldvol = vol;
        oldag = ag;
        oldme = me;
        Serial2.write(vol);
        ag = 5;
        me = 5;
        gr = 5;
        ActualizarSliderA();
        ActualizarSliderG();
        ActualizarSliderM();
      } else  if (op == 64)   //POP
      {
        Serial2.write(vol);
        oldgr = gr;
        oldvol = vol;
        oldag = ag;
        oldme = me;
        ag = 5;
        me = 5;
        gr = 5;
        ActualizarSliderA();
        ActualizarSliderG();
        ActualizarSliderM();
      }
    }
    vTaskDelay(10);
  }
}

static void salidastask(void *pvParameters) {
  int grenviado, meenviado, meagenviado, agenviado;;
  while (1) {

    volflo = vol;
    grenviado = int((map(gr, 0, 10, 0, 255) * (volflo / 10)));
    potWrite(0, grenviado);
    meenviado = int((map(me, 0, 10, 0, 255) * (volflo / 10)));
    potWrite(1, meenviado);
    meagenviado = int((map(meag, 0, 10, 0, 255) * (volflo / 10)));
    potWrite(2, meagenviado);
    agenviado = int((map(ag, 0, 10, 0, 255) * (volflo / 10)));
    potWrite(3, agenviado);

    Serial.println(grenviado);


    vTaskDelay(300);
  }
}


void potWrite(int address, int valor) {  //value
  // take the SS pin low to select the chip:
  //digitalWrite(TFT_CS, HIGH); //REVISAR*****************************************************************************************************
  digitalWrite(slaveSelectPin, LOW);
  delay(100);
  //  send in the address and value via SPI:
  SPI.transfer(address);
  SPI.transfer(valor); //value
  delay(100);
  // take the SS pin high to de-select the chip:
  digitalWrite(slaveSelectPin, HIGH);
  Serial.print("COMUNICACION FINALIZADA addres : ");
  Serial.println(address);
  Serial.print("valor: ");
  Serial.println(valor);
}


/*
  static void pwmtask(void *pvParameters) {


  /*Si 1000 ticks=1seg, 0.01ticks => 100KHz de frecuencia
     Delay total de la funcion debe ser 0.01

     PWMA= __----______
     PWMB= _______----_

     SIEMPRE TIENE QUE CUMPLIRSE:  tONA+tOFF+tONB+tOFF = 0.1
*/
/*
  float toff = 0.001;
  while (1)
  {
  digitalWrite(PWMA, HIGH);
  vTaskDelay(0.005 - toff);   // 50% -tOFF = tON
  digitalWrite(PWMA, LOW);
  vTaskDelay(toff);
  digitalWrite(PWMB, HIGH);
  vTaskDelay(0.005 - toff);
  digitalWrite(PWMB, LOW);
  vTaskDelay(toff);
  }
  }*/
