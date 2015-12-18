int AnalogPin0 = A0; //Declare an integer variable, hooked up to analog pin 0
int AnalogPin1 = A1; //Declare an integer variable, hooked up to analog pin 1
int AnalogPin2 = A2; //Declare an integer variable, hooked up to analog pin 2

void setup() {
  Serial.begin(9600); //Begin Serial Communication with a baud rate of 9600
}

void loop() {
   //New variables are declared to store the readings of the respective pins
  int Value1 = analogRead(AnalogPin0);
  int Value2 = analogRead(AnalogPin1);
  int Value3 = analogRead(AnalogPin2);

  
  Serial.print(Value1, DEC); 
  Serial.print(",");
  Serial.print(Value2, DEC);
  Serial.print(",");
  Serial.print(Value3, DEC);
    Serial.print(",");

  Serial.println();
  delay(500);
}
