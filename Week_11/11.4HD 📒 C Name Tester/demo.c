#include <stdio.h>
#include <string.h>
#include "terminal_user_input.h"

#define CAR_SIZE 3

typedef struct car_data
{
  char color[256];
  char model[256];
  int year;
} car_data;

car_data read_car()
{
  car_data result;

  printf("\n Enter car color: ");
  scanf("%255[^\n]%*c", result.color);
  printf("\n Enter car model: ");
  scanf("%255[^\n]%*c", result.model);
  result.year = read_integer("\n Enter year: ");

  return result;
}

void populate_car_array(car_data data[], int size)
{
  int i;

  for(i = 0; i < size; i++)
  {
    data[i] = read_car();
  }
}

void print_car(car_data car)
{
  printf("\nCar Colour: %s", car.color);
  printf("\nCar Model: %s", car.model);
  printf("\nCar year: %d", car.year);
}

void print_car_array(car_data data[], int size)
{
  int i;

  for(i = 0; i < size; i++)
  {
    print_car(data[i]);
  }

}

int main()
{
  car_data cars[CAR_SIZE];

  populate_car_array(cars, CAR_SIZE);
  print_car_array(cars, CAR_SIZE);

  return 0; // exit... with result 0
}