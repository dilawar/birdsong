/*
 * ==============================================================================
 *
 *       Filename:  global.h
 *
 *    Description:  globals
 *
 *        Version:  1.0
 *        Created:  11/19/2014 08:51:11 PM
 *       Revision:  none
 *       Compiler:  gcc
 *
 *         Author:  Dilawar Singh (), dilawars@ncbs.res.in
 *   Organization:  
 *
 * ==============================================================================
 */
#ifndef  GLOBAL_INC
#define  GLOBAL_INC

#include <algorithm>
#include <functional>
#include <memory>
#include "simple_test.hpp"
#include "simple_logger.hpp"
#include "testing_macros.hpp"
#include <boost/program_options.hpp>

#define PI 3.141592654
#define CONFIG_FILE "songbird.conf"


extern boost::program_options::variables_map prgOptions;

#endif   /* ----- #ifndef GLOBAL_INC  ----- */
