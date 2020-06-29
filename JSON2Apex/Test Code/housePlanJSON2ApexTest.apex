@IsTest
public class housePlanJSON2ApexTest {
	
	// This test method should give 100% coverage
	static testMethod void testParse() {
		String json = '{'+
		'  \"id\": \"AY9DKPj3\",'+
		'  \"name\": \"Payne\'s Mill 23\",'+
		'  \"lighting\": {'+
		'    \"percentEfficient\": {'+
		'      \"interior\": 0,'+
		'      \"exterior\": 0,'+
		'      \"garage\": 0'+
		'    },'+
		'    \"percentLED\": {'+
		'      \"interior\": 95.5,'+
		'      \"exterior\": 100,'+
		'      \"garage\": 0'+
		'    }'+
		'  },'+
		'  \"appliances\": {'+
		'    \"dishwasherEfficiencyType\": \"kWh\",'+
		'    \"dishwasherEfficiency\": 270,'+
		'    \"dishwasherPlaceSettings\": 12,'+
		'    \"refrigeratorConsumption\": 691,'+
		'    \"clothesDryer\": {'+
		'      \"fuel\": \"ELECTRIC\",'+
		'      \"combinedEfficiencyFactor\": 2.61739,'+
		'      \"utilizationFactor\": \"TIMER_CONTROLS\"'+
		'    },'+
		'    \"clothesWasher\": {'+
		'      \"labeledEnergyRating\": 704,'+
		'      \"electricRate\": 0.0803,'+
		'      \"gasRate\": 0.58,'+
		'      \"annualGasCost\": 23,'+
		'      \"capacity\": 2.874,'+
		'      \"integratedModifiedEnergyFactor\": 0.33053'+
		'    },'+
		'    \"rangeOven\": {'+
		'      \"fuel\": \"ELECTRIC\"'+
		'    }'+
		'  },'+
		'  \"thermalEnvelope\": {'+
		'    \"summary\": {'+
		'      \"conditionedArea\": 3009,'+
		'      \"conditionedVolume\": 28084,'+
		'      \"windowArea\": 492.5,'+
		'      \"wallArea\": 2244,'+
		'      \"floorArea\": 0,'+
		'      \"ceilingArea\": 1003,'+
		'      \"slabArea\": 1003,'+
		'      \"totalThermalBoundaryArea\": 5702,'+
		'      \"aboveGradeThermalBoundaryArea\": 3643,'+
		'      \"dominantWallType\": {'+
		'        \"id\": \"bkrOPWO6\",'+
		'        \"name\": \"R-15 Gr2\",'+
		'        \"description\": \"\",'+
		'        \"uFactor\": 0.07909796678676374,'+
		'        \"hasAssemblyDetails\": true,'+
		'        \"assemblyDetails\": {'+
		'          \"cavityR\": 15,'+
		'          \"cavityInsulationGrade\": ['+
		'            \"II\"'+
		'          ],'+
		'          \"cavityInsulationMaterial\": ['+
		'            \"FiberglassBatts\"'+
		'          ],'+
		'          \"continuousR\": 0,'+
		'          \"framingSpacing\": ['+
		'            16'+
		'          ],'+
		'          \"framingDepth\": ['+
		'            3.5'+
		'          ],'+
		'          \"framingFraction\": ['+
		'            0.23005'+
		'          ]'+
		'        },'+
		'        \"isVerified\": false'+
		'      },'+
		'      \"dominantFoundationWallType\": {'+
		'        \"id\": \"6MMmM1J6\",'+
		'        \"name\": \"R-13 16oc gr2\",'+
		'        \"description\": \"\",'+
		'        \"uFactor\": 0.11699775012837173,'+
		'        \"hasAssemblyDetails\": true,'+
		'        \"assemblyDetails\": {'+
		'          \"cavityR\": 12.950000000000001,'+
		'          \"cavityInsulationGrade\": ['+
		'            \"II\"'+
		'          ],'+
		'          \"cavityInsulationMaterial\": ['+
		'            \"FiberglassBatts\"'+
		'          ],'+
		'          \"continuousR\": 0,'+
		'          \"framingSpacing\": ['+
		'            16'+
		'          ],'+
		'          \"framingDepth\": ['+
		'            3.5'+
		'          ],'+
		'          \"framingFraction\": ['+
		'            0.23005'+
		'          ]'+
		'        },'+
		'        \"isVerified\": false,'+
		'        \"rFactor\": 8.547172906340375,'+
		'        \"distanceInsulationTopToTop\": 0,'+
		'        \"distanceInsulationBottomToTop\": 0'+
		'      },'+
		'      \"dominantSlabType\": {'+
		'        \"id\": \"Y1LeGkLV\",'+
		'        \"name\": \"Uninsulated\",'+
		'        \"description\": \"\",'+
		'        \"isVerified\": false,'+
		'        \"slabCompletelyInsulated\": false,'+
		'        \"perimeterRValue\": 0,'+
		'        \"underSlabRValue\": 0,'+
		'        \"underslabInsulationWidth\": 0,'+
		'        \"perimeterInsulationDepth\": 0'+
		'      },'+
		'      \"dominantRimJoistType\": {'+
		'        \"id\": \"bvd20K1Y\",'+
		'        \"name\": \"R-15\",'+
		'        \"description\": \"\",'+
		'        \"isVerified\": false,'+
		'        \"uFactor\": 0.06666666666666667,'+
		'        \"rFactor\": 15'+
		'      },'+
		'      \"dominantCeilingType\": {'+
		'        \"id\": \"Y3J2GerV\",'+
		'        \"name\": \"R-38 Blown, Attic\",'+
		'        \"description\": \"\",'+
		'        \"uFactor\": 0.026232260433881587,'+
		'        \"hasAssemblyDetails\": true,'+
		'        \"assemblyDetails\": {'+
		'          \"cavityR\": 13,'+
		'          \"cavityInsulationGrade\": ['+
		'            \"I\"'+
		'          ],'+
		'          \"cavityInsulationMaterial\": ['+
		'            \"CelluloseAttic\"'+
		'          ],'+
		'          \"continuousR\": 25,'+
		'          \"framingSpacing\": ['+
		'            24'+
		'          ],'+
		'          \"framingDepth\": ['+
		'            3.5'+
		'          ],'+
		'          \"framingFraction\": ['+
		'            0.11'+
		'          ]'+
		'        },'+
		'        \"isVerified\": false,'+
		'        \"radiantBarrier\": false'+
		'      },'+
		'      \"dominantWindowType\": {'+
		'        \"id\": \"6ZRMDkL6\",'+
		'        \"name\": \"0.29 / 0.23\",'+
		'        \"description\": \"\",'+
		'        \"uFactor\": 0.29,'+
		'        \"SHGC\": 0.23,'+
		'        \"isVerified\": false'+
		'      },'+
		'      \"dominantDoorType\": {'+
		'        \"id\": \"nYNE4qJV\",'+
		'        \"name\": \"R-7\",'+
		'        \"description\": \"\",'+
		'        \"isVerified\": false,'+
		'        \"uFactor\": 0.14285714285714285'+
		'      }'+
		'    },'+
		'    \"infiltration\": {'+
		'      \"fieldTestStatus\": \"Tested\",'+
		'      \"cfm50\": 1295,'+
		'      \"ach50\": 2.766699900299103,'+
		'      \"effectiveLeakageArea\": 71.225,'+
		'      \"specificLeakageArea\": 0.00016427434363575937,'+
		'      \"heatingNaturalACH\": 0.16085464536622693,'+
		'      \"coolingNaturalACH\": 0.16085464536622693'+
		'    },'+
		'    \"foundationType\": \"CONDITIONED_BASEMENT\",'+
		'    \"slabs\": ['+
		'      {'+
		'        \"name\": \"below grade\",'+
		'        \"encloses\": \"ConditionedSpace\",'+
		'        \"surfaceArea\": 1003,'+
		'        \"exteriorPerimeter\": 132,'+
		'        \"exposedMasonryArea\": 326,'+
		'        \"grade\": \"BelowGrade\",'+
		'        \"type\": {'+
		'          \"id\": \"Y1LeGkLV\",'+
		'          \"name\": \"Uninsulated\",'+
		'          \"description\": \"\",'+
		'          \"isVerified\": false,'+
		'          \"slabCompletelyInsulated\": false,'+
		'          \"perimeterRValue\": 0,'+
		'          \"underSlabRValue\": 0,'+
		'          \"underslabInsulationWidth\": 0,'+
		'          \"perimeterInsulationDepth\": 0'+
		'        }'+
		'      }'+
		'    ],'+
		'    \"framedFloors\": [],'+
		'    \"foundationWalls\": ['+
		'      {'+
		'        \"name\": \"unfinished\",'+
		'        \"encloses\": \"ConditionedSpace\",'+
		'        \"betweenInteriorAnd\": \"ExposedExterior\",'+
		'        \"heightAboveGrade\": 1,'+
		'        \"depthBelowGrade\": 8,'+
		'        \"perimeter\": 39,'+
		'        \"type\": {'+
		'          \"id\": \"nb2p2xdY\",'+
		'          \"name\": \"R-11 Draped, Full\",'+
		'          \"description\": \"\",'+
		'          \"uFactor\": 0.09090909090909091,'+
		'          \"hasAssemblyDetails\": false,'+
		'          \"isVerified\": false,'+
		'          \"rFactor\": 11,'+
		'          \"distanceInsulationTopToTop\": 0,'+
		'          \"distanceInsulationBottomToTop\": 0'+
		'        }'+
		'      },'+
		'      {'+
		'        \"name\": \"finished\",'+
		'        \"encloses\": \"ConditionedSpace\",'+
		'        \"betweenInteriorAnd\": \"ExposedExterior\",'+
		'        \"heightAboveGrade\": 1,'+
		'        \"depthBelowGrade\": 8,'+
		'        \"perimeter\": 93,'+
		'        \"type\": {'+
		'          \"id\": \"6MMmM1J6\",'+
		'          \"name\": \"R-13 16oc gr2\",'+
		'          \"description\": \"\",'+
		'          \"uFactor\": 0.11699775012837173,'+
		'          \"hasAssemblyDetails\": true,'+
		'          \"assemblyDetails\": {'+
		'            \"cavityR\": 12.950000000000001,'+
		'            \"cavityInsulationGrade\": ['+
		'              \"II\"'+
		'            ],'+
		'            \"cavityInsulationMaterial\": ['+
		'              \"FiberglassBatts\"'+
		'            ],'+
		'            \"continuousR\": 0,'+
		'            \"framingSpacing\": ['+
		'              16'+
		'            ],'+
		'            \"framingDepth\": ['+
		'              3.5'+
		'            ],'+
		'            \"framingFraction\": ['+
		'              0.23005'+
		'            ]'+
		'          },'+
		'          \"isVerified\": false,'+
		'          \"rFactor\": 8.547172906340375,'+
		'          \"distanceInsulationTopToTop\": 0,'+
		'          \"distanceInsulationBottomToTop\": 0'+
		'        }'+
		'      }'+
		'    ],'+
		'    \"walls\": ['+
		'      {'+
		'        \"name\": \"2x4 to ambient\",'+
		'        \"surfaceColor\": \"Medium\",'+
		'        \"betweenInteriorAnd\": \"ExposedExterior\",'+
		'        \"surfaceArea\": 2244,'+
		'        \"type\": {'+
		'          \"id\": \"bkrOPWO6\",'+
		'          \"name\": \"R-15 Gr2\",'+
		'          \"description\": \"\",'+
		'          \"uFactor\": 0.07909796678676374,'+
		'          \"hasAssemblyDetails\": true,'+
		'          \"assemblyDetails\": {'+
		'            \"cavityR\": 15,'+
		'            \"cavityInsulationGrade\": ['+
		'              \"II\"'+
		'            ],'+
		'            \"cavityInsulationMaterial\": ['+
		'              \"FiberglassBatts\"'+
		'            ],'+
		'            \"continuousR\": 0,'+
		'            \"framingSpacing\": ['+
		'              16'+
		'            ],'+
		'            \"framingDepth\": ['+
		'              3.5'+
		'            ],'+
		'            \"framingFraction\": ['+
		'              0.23005'+
		'            ]'+
		'          },'+
		'          \"isVerified\": false'+
		'        }'+
		'      }'+
		'    ],'+
		'    \"rimJoists\": ['+
		'      {'+
		'        \"name\": \"to ambient\",'+
		'        \"betweenInteriorAnd\": \"ExposedExterior\",'+
		'        \"surfaceArea\": 264,'+
		'        \"type\": {'+
		'          \"id\": \"bvd20K1Y\",'+
		'          \"name\": \"R-15\",'+
		'          \"description\": \"\",'+
		'          \"isVerified\": false,'+
		'          \"uFactor\": 0.06666666666666667,'+
		'          \"rFactor\": 15'+
		'        }'+
		'      }'+
		'    ],'+
		'    \"ceilings\": ['+
		'      {'+
		'        \"name\": \"blown\",'+
		'        \"surfaceColor\": \"Dark\",'+
		'        \"betweenInteriorAnd\": \"VentedAttic\",'+
		'        \"surfaceArea\": 1003,'+
		'        \"roofDeckArea\": 1427,'+
		'        \"clayConcreteRoofTiles\": false,'+
		'        \"type\": {'+
		'          \"id\": \"Y3J2GerV\",'+
		'          \"name\": \"R-38 Blown, Attic\",'+
		'          \"description\": \"\",'+
		'          \"uFactor\": 0.026232260433881587,'+
		'          \"hasAssemblyDetails\": true,'+
		'          \"assemblyDetails\": {'+
		'            \"cavityR\": 13,'+
		'            \"cavityInsulationGrade\": ['+
		'              \"I\"'+
		'            ],'+
		'            \"cavityInsulationMaterial\": ['+
		'              \"CelluloseAttic\"'+
		'            ],'+
		'            \"continuousR\": 25,'+
		'            \"framingSpacing\": ['+
		'              24'+
		'            ],'+
		'            \"framingDepth\": ['+
		'              3.5'+
		'            ],'+
		'            \"framingFraction\": ['+
		'              0.11'+
		'            ]'+
		'          },'+
		'          \"isVerified\": false,'+
		'          \"radiantBarrier\": false'+
		'        }'+
		'      }'+
		'    ],'+
		'    \"windows\": ['+
		'      {'+
		'        \"name\": \"FR dining\",'+
		'        \"orientation\": \"Southeast\",'+
		'        \"installedWallIndex\": 0,'+
		'        \"surfaceArea\": 60,'+
		'        \"type\": {'+
		'          \"id\": \"6ZRMDkL6\",'+
		'          \"name\": \"0.29 / 0.23\",'+
		'          \"description\": \"\",'+
		'          \"uFactor\": 0.29,'+
		'          \"SHGC\": 0.23,'+
		'          \"isVerified\": false'+
		'        },'+
		'        \"overhangDepth\": 4.5,'+
		'        \"distanceOverhangToTop\": 1,'+
		'        \"distanceOverhangToBottom\": 7,'+
		'        \"shadingFactors\": {'+
		'          \"interior\": {'+
		'            \"summer\": 0.7,'+
		'            \"winter\": 0.85'+
		'          },'+
		'          \"adjacent\": {'+
		'            \"summer\": 1,'+
		'            \"winter\": 1'+
		'          }'+
		'        }'+
		'      },'+
		'      {'+
		'        \"name\": \"FR foyer\",'+
		'        \"orientation\": \"Southeast\",'+
		'        \"installedWallIndex\": 0,'+
		'        \"surfaceArea\": 36,'+
		'        \"type\": {'+
		'          \"id\": \"6ZRMDkL6\",'+
		'          \"name\": \"0.29 / 0.23\",'+
		'          \"description\": \"\",'+
		'          \"uFactor\": 0.29,'+
		'          \"SHGC\": 0.23,'+
		'          \"isVerified\": false'+
		'        },'+
		'        \"overhangDepth\": 2,'+
		'        \"distanceOverhangToTop\": 0.5,'+
		'        \"distanceOverhangToBottom\": 6.5,'+
		'        \"shadingFactors\": {'+
		'          \"interior\": {'+
		'            \"summer\": 0.7,'+
		'            \"winter\": 0.85'+
		'          },'+
		'          \"adjacent\": {'+
		'            \"summer\": 1,'+
		'            \"winter\": 1'+
		'          }'+
		'        }'+
		'      },'+
		'      {'+
		'        \"name\": \"FR hall\",'+
		'        \"orientation\": \"Southeast\",'+
		'        \"installedWallIndex\": 0,'+
		'        \"surfaceArea\": 31,'+
		'        \"type\": {'+
		'          \"id\": \"6ZRMDkL6\",'+
		'          \"name\": \"0.29 / 0.23\",'+
		'          \"description\": \"\",'+
		'          \"uFactor\": 0.29,'+
		'          \"SHGC\": 0.23,'+
		'          \"isVerified\": false'+
		'        },'+
		'        \"overhangDepth\": 0,'+
		'        \"distanceOverhangToTop\": 0,'+
		'        \"distanceOverhangToBottom\": 0,'+
		'        \"shadingFactors\": {'+
		'          \"interior\": {'+
		'            \"summer\": 0.7,'+
		'            \"winter\": 0.85'+
		'          },'+
		'          \"adjacent\": {'+
		'            \"summer\": 1,'+
		'            \"winter\": 1'+
		'          }'+
		'        }'+
		'      },'+
		'      {'+
		'        \"name\": \"FR master bed\",'+
		'        \"orientation\": \"Southeast\",'+
		'        \"installedWallIndex\": 0,'+
		'        \"surfaceArea\": 24,'+
		'        \"type\": {'+
		'          \"id\": \"6ZRMDkL6\",'+
		'          \"name\": \"0.29 / 0.23\",'+
		'          \"description\": \"\",'+
		'          \"uFactor\": 0.29,'+
		'          \"SHGC\": 0.23,'+
		'          \"isVerified\": false'+
		'        },'+
		'        \"overhangDepth\": 1.5,'+
		'        \"distanceOverhangToTop\": 1,'+
		'        \"distanceOverhangToBottom\": 7,'+
		'        \"shadingFactors\": {'+
		'          \"interior\": {'+
		'            \"summer\": 0.7,'+
		'            \"winter\": 0.85'+
		'          },'+
		'          \"adjacent\": {'+
		'            \"summer\": 1,'+
		'            \"winter\": 1'+
		'          }'+
		'        }'+
		'      },'+
		'      {'+
		'        \"name\": \"FR master bed doors\",'+
		'        \"orientation\": \"Southeast\",'+
		'        \"installedWallIndex\": 0,'+
		'        \"surfaceArea\": 40,'+
		'        \"type\": {'+
		'          \"id\": \"VzzjJG2V\",'+
		'          \"name\": \"0.29 / 0.25\",'+
		'          \"description\": \"\",'+
		'          \"uFactor\": 0.29,'+
		'          \"SHGC\": 0.25,'+
		'          \"isVerified\": false'+
		'        },'+
		'        \"overhangDepth\": 1.5,'+
		'        \"distanceOverhangToTop\": 1,'+
		'        \"distanceOverhangToBottom\": 7.7,'+
		'        \"shadingFactors\": {'+
		'          \"interior\": {'+
		'            \"summer\": 0.7,'+
		'            \"winter\": 0.85'+
		'          },'+
		'          \"adjacent\": {'+
		'            \"summer\": 1,'+
		'            \"winter\": 1'+
		'          }'+
		'        }'+
		'      },'+
		'      {'+
		'        \"name\": \"LT dining\",'+
		'        \"orientation\": \"Southwest\",'+
		'        \"installedWallIndex\": 0,'+
		'        \"surfaceArea\": 36,'+
		'        \"type\": {'+
		'          \"id\": \"6ZRMDkL6\",'+
		'          \"name\": \"0.29 / 0.23\",'+
		'          \"description\": \"\",'+
		'          \"uFactor\": 0.29,'+
		'          \"SHGC\": 0.23,'+
		'          \"isVerified\": false'+
		'        },'+
		'        \"overhangDepth\": 0,'+
		'        \"distanceOverhangToTop\": 0,'+
		'        \"distanceOverhangToBottom\": 0,'+
		'        \"shadingFactors\": {'+
		'          \"interior\": {'+
		'            \"summer\": 0.7,'+
		'            \"winter\": 0.85'+
		'          },'+
		'          \"adjacent\": {'+
		'            \"summer\": 1,'+
		'            \"winter\": 1'+
		'          }'+
		'        }'+
		'      },'+
		'      {'+
		'        \"name\": \"LT great room\",'+
		'        \"orientation\": \"Southwest\",'+
		'        \"installedWallIndex\": 0,'+
		'        \"surfaceArea\": 36,'+
		'        \"type\": {'+
		'          \"id\": \"6ZRMDkL6\",'+
		'          \"name\": \"0.29 / 0.23\",'+
		'          \"description\": \"\",'+
		'          \"uFactor\": 0.29,'+
		'          \"SHGC\": 0.23,'+
		'          \"isVerified\": false'+
		'        },'+
		'        \"overhangDepth\": 0,'+
		'        \"distanceOverhangToTop\": 0,'+
		'        \"distanceOverhangToBottom\": 0,'+
		'        \"shadingFactors\": {'+
		'          \"interior\": {'+
		'            \"summer\": 0.7,'+
		'            \"winter\": 0.85'+
		'          },'+
		'          \"adjacent\": {'+
		'            \"summer\": 1,'+
		'            \"winter\": 1'+
		'          }'+
		'        }'+
		'      },'+
		'      {'+
		'        \"name\": \"LT basement bedroom\",'+
		'        \"orientation\": \"Southwest\",'+
		'        \"installedFoundationWallIndex\": 0,'+
		'        \"surfaceArea\": 15.5,'+
		'        \"type\": {'+
		'          \"id\": \"6ZRMDkL6\",'+
		'          \"name\": \"0.29 / 0.23\",'+
		'          \"description\": \"\",'+
		'          \"uFactor\": 0.29,'+
		'          \"SHGC\": 0.23,'+
		'          \"isVerified\": false'+
		'        },'+
		'        \"overhangDepth\": 0,'+
		'        \"distanceOverhangToTop\": 0,'+
		'        \"distanceOverhangToBottom\": 0,'+
		'        \"shadingFactors\": {'+
		'          \"interior\": {'+
		'            \"summer\": 0.7,'+
		'            \"winter\": 0.85'+
		'          },'+
		'          \"adjacent\": {'+
		'            \"summer\": 0,'+
		'            \"winter\": 0'+
		'          }'+
		'        }'+
		'      },'+
		'      {'+
		'        \"name\": \"LT master bath\",'+
		'        \"orientation\": \"Southwest\",'+
		'        \"installedWallIndex\": 0,'+
		'        \"surfaceArea\": 12,'+
		'        \"type\": {'+
		'          \"id\": \"6ZRMDkL6\",'+
		'          \"name\": \"0.29 / 0.23\",'+
		'          \"description\": \"\",'+
		'          \"uFactor\": 0.29,'+
		'          \"SHGC\": 0.23,'+
		'          \"isVerified\": false'+
		'        },'+
		'        \"overhangDepth\": 0,'+
		'        \"distanceOverhangToTop\": 0,'+
		'        \"distanceOverhangToBottom\": 0,'+
		'        \"shadingFactors\": {'+
		'          \"interior\": {'+
		'            \"summer\": 0.7,'+
		'            \"winter\": 0.85'+
		'          },'+
		'          \"adjacent\": {'+
		'            \"summer\": 1,'+
		'            \"winter\": 1'+
		'          }'+
		'        }'+
		'      },'+
		'      {'+
		'        \"name\": \"BK kitchen/great room\",'+
		'        \"orientation\": \"Northwest\",'+
		'        \"installedWallIndex\": 0,'+
		'        \"surfaceArea\": 54,'+
		'        \"type\": {'+
		'          \"id\": \"6ZRMDkL6\",'+
		'          \"name\": \"0.29 / 0.23\",'+
		'          \"description\": \"\",'+
		'          \"uFactor\": 0.29,'+
		'          \"SHGC\": 0.23,'+
		'          \"isVerified\": false'+
		'        },'+
		'        \"overhangDepth\": 0,'+
		'        \"distanceOverhangToTop\": 0,'+
		'        \"distanceOverhangToBottom\": 0,'+
		'        \"shadingFactors\": {'+
		'          \"interior\": {'+
		'            \"summer\": 0.7,'+
		'            \"winter\": 0.85'+
		'          },'+
		'          \"adjacent\": {'+
		'            \"summer\": 1,'+
		'            \"winter\": 1'+
		'          }'+
		'        }'+
		'      },'+
		'      {'+
		'        \"name\": \"BK doors\",'+
		'        \"orientation\": \"Northwest\",'+
		'        \"installedWallIndex\": 0,'+
		'        \"surfaceArea\": 40,'+
		'        \"type\": {'+
		'          \"id\": \"Yxk1G1rV\",'+
		'          \"name\": \"T-tru 1/1 lite 0.36/0.34\",'+
		'          \"description\": \"\",'+
		'          \"uFactor\": 0.36,'+
		'          \"SHGC\": 0.34,'+
		'          \"isVerified\": false'+
		'        },'+
		'        \"overhangDepth\": 0,'+
		'        \"distanceOverhangToTop\": 0,'+
		'        \"distanceOverhangToBottom\": 0,'+
		'        \"shadingFactors\": {'+
		'          \"interior\": {'+
		'            \"summer\": 0.7,'+
		'            \"winter\": 0.85'+
		'          },'+
		'          \"adjacent\": {'+
		'            \"summer\": 1,'+
		'            \"winter\": 1'+
		'          }'+
		'        }'+
		'      },'+
		'      {'+
		'        \"name\": \"BK beds 2&3\",'+
		'        \"orientation\": \"Northwest\",'+
		'        \"installedWallIndex\": 0,'+
		'        \"surfaceArea\": 31,'+
		'        \"type\": {'+
		'          \"id\": \"6ZRMDkL6\",'+
		'          \"name\": \"0.29 / 0.23\",'+
		'          \"description\": \"\",'+
		'          \"uFactor\": 0.29,'+
		'          \"SHGC\": 0.23,'+
		'          \"isVerified\": false'+
		'        },'+
		'        \"overhangDepth\": 1.5,'+
		'        \"distanceOverhangToTop\": 1,'+
		'        \"distanceOverhangToBottom\": 6.2,'+
		'        \"shadingFactors\": {'+
		'          \"interior\": {'+
		'            \"summer\": 0.7,'+
		'            \"winter\": 0.85'+
		'          },'+
		'          \"adjacent\": {'+
		'            \"summer\": 1,'+
		'            \"winter\": 1'+
		'          }'+
		'        }'+
		'      },'+
		'      {'+
		'        \"name\": \"BK basement rec room\",'+
		'        \"orientation\": \"Northwest\",'+
		'        \"installedFoundationWallIndex\": 1,'+
		'        \"surfaceArea\": 15.5,'+
		'        \"type\": {'+
		'          \"id\": \"6ZRMDkL6\",'+
		'          \"name\": \"0.29 / 0.23\",'+
		'          \"description\": \"\",'+
		'          \"uFactor\": 0.29,'+
		'          \"SHGC\": 0.23,'+
		'          \"isVerified\": false'+
		'        },'+
		'        \"overhangDepth\": 0,'+
		'        \"distanceOverhangToTop\": 0,'+
		'        \"distanceOverhangToBottom\": 0,'+
		'        \"shadingFactors\": {'+
		'          \"interior\": {'+
		'            \"summer\": 0.7,'+
		'            \"winter\": 0.85'+
		'          },'+
		'          \"adjacent\": {'+
		'            \"summer\": 0,'+
		'            \"winter\": 0'+
		'          }'+
		'        }'+
		'      },'+
		'      {'+
		'        \"name\": \"RT foyer\",'+
		'        \"orientation\": \"Northeast\",'+
		'        \"installedWallIndex\": 0,'+
		'        \"surfaceArea\": 18,'+
		'        \"type\": {'+
		'          \"id\": \"6ZRMDkL6\",'+
		'          \"name\": \"0.29 / 0.23\",'+
		'          \"description\": \"\",'+
		'          \"uFactor\": 0.29,'+
		'          \"SHGC\": 0.23,'+
		'          \"isVerified\": false'+
		'        },'+
		'        \"overhangDepth\": 0,'+
		'        \"distanceOverhangToTop\": 0,'+
		'        \"distanceOverhangToBottom\": 0,'+
		'        \"shadingFactors\": {'+
		'          \"interior\": {'+
		'            \"summer\": 0.7,'+
		'            \"winter\": 0.85'+
		'          },'+
		'          \"adjacent\": {'+
		'            \"summer\": 1,'+
		'            \"winter\": 1'+
		'          }'+
		'        }'+
		'      },'+
		'      {'+
		'        \"name\": \"RT kitchen\",'+
		'        \"orientation\": \"Northeast\",'+
		'        \"installedWallIndex\": 0,'+
		'        \"surfaceArea\": 12,'+
		'        \"type\": {'+
		'          \"id\": \"6ZRMDkL6\",'+
		'          \"name\": \"0.29 / 0.23\",'+
		'          \"description\": \"\",'+
		'          \"uFactor\": 0.29,'+
		'          \"SHGC\": 0.23,'+
		'          \"isVerified\": false'+
		'        },'+
		'        \"overhangDepth\": 0,'+
		'        \"distanceOverhangToTop\": 0,'+
		'        \"distanceOverhangToBottom\": 0,'+
		'        \"shadingFactors\": {'+
		'          \"interior\": {'+
		'            \"summer\": 0.7,'+
		'            \"winter\": 0.85'+
		'          },'+
		'          \"adjacent\": {'+
		'            \"summer\": 1,'+
		'            \"winter\": 1'+
		'          }'+
		'        }'+
		'      },'+
		'      {'+
		'        \"name\": \"RT landing/bath 2\",'+
		'        \"orientation\": \"Northeast\",'+
		'        \"installedWallIndex\": 0,'+
		'        \"surfaceArea\": 16,'+
		'        \"type\": {'+
		'          \"id\": \"6ZRMDkL6\",'+
		'          \"name\": \"0.29 / 0.23\",'+
		'          \"description\": \"\",'+
		'          \"uFactor\": 0.29,'+
		'          \"SHGC\": 0.23,'+
		'          \"isVerified\": false'+
		'        },'+
		'        \"overhangDepth\": 0,'+
		'        \"distanceOverhangToTop\": 0,'+
		'        \"distanceOverhangToBottom\": 0,'+
		'        \"shadingFactors\": {'+
		'          \"interior\": {'+
		'            \"summer\": 0.7,'+
		'            \"winter\": 0.85'+
		'          },'+
		'          \"adjacent\": {'+
		'            \"summer\": 1,'+
		'            \"winter\": 1'+
		'          }'+
		'        }'+
		'      },'+
		'      {'+
		'        \"name\": \"RT hall\",'+
		'        \"orientation\": \"Northeast\",'+
		'        \"installedWallIndex\": 0,'+
		'        \"surfaceArea\": 15.5,'+
		'        \"type\": {'+
		'          \"id\": \"6ZRMDkL6\",'+
		'          \"name\": \"0.29 / 0.23\",'+
		'          \"description\": \"\",'+
		'          \"uFactor\": 0.29,'+
		'          \"SHGC\": 0.23,'+
		'          \"isVerified\": false'+
		'        },'+
		'        \"overhangDepth\": 1.5,'+
		'        \"distanceOverhangToTop\": 1,'+
		'        \"distanceOverhangToBottom\": 6.2,'+
		'        \"shadingFactors\": {'+
		'          \"interior\": {'+
		'            \"summer\": 0.7,'+
		'            \"winter\": 0.85'+
		'          },'+
		'          \"adjacent\": {'+
		'            \"summer\": 1,'+
		'            \"winter\": 1'+
		'          }'+
		'        }'+
		'      }'+
		'    ],'+
		'    \"skylights\": [],'+
		'    \"doors\": ['+
		'      {'+
		'        \"name\": \"front entry\",'+
		'        \"installedWallIndex\": 0,'+
		'        \"surfaceArea\": 20,'+
		'        \"type\": {'+
		'          \"id\": \"nYNE4qJV\",'+
		'          \"name\": \"R-7\",'+
		'          \"description\": \"\",'+
		'          \"isVerified\": false,'+
		'          \"uFactor\": 0.14285714285714285'+
		'        }'+
		'      }'+
		'    ]'+
		'  },'+
		'  \"mechanicals\": {'+
		'    \"summary\": {'+
		'      \"ductSystemCount\": 1,'+
		'      \"ductLeakageTotal\": 161,'+
		'      \"ductLeakageToOutside\": 11,'+
		'      \"mechanicalVentilationRate\": 65,'+
		'      \"dominantHeatingEquipmentType\": {'+
		'        \"id\": \"nb2PlqoY\",'+
		'        \"name\": \"58k furnace, 96.3%, 254kWh\",'+
		'        \"description\": \"\",'+
		'        \"fuel\": \"NATURAL_GAS\",'+
		'        \"equipmentType\": \"FURNACE\",'+
		'        \"motorType\": \"VariableSpeed\",'+
		'        \"isVerified\": false,'+
		'        \"ahriReferenceNumber\": \"\",'+
		'        \"usingDefaultElectricAuxiliaryEnergy\": false,'+
		'        \"electricAuxiliaryEnergy\": 254,'+
		'        \"heating\": {'+
		'          \"efficiency\": 96.3,'+
		'          \"efficiencyType\": \"AFUE\",'+
		'          \"capacity\": 58'+
		'        },'+
		'        \"cooling\": {'+
		'          \"efficiency\": 0,'+
		'          \"efficiencyType\": \"SEER\",'+
		'          \"capacity\": 0'+
		'        },'+
		'        \"hotWater\": {'+
		'          \"efficiency\": 0,'+
		'          \"efficiencyType\": \"ENERGY_FACTOR\",'+
		'          \"isTankless\": false,'+
		'          \"tankSize\": 0'+
		'        }'+
		'      },'+
		'      \"dominantCoolingEquipmentType\": {'+
		'        \"id\": \"bLDL1lqb\",'+
		'        \"name\": \"33.4k 15seer\",'+
		'        \"description\": \"\",'+
		'        \"fuel\": \"ELECTRIC\",'+
		'        \"equipmentType\": \"AIR_CONDITIONER\",'+
		'        \"motorType\": \"VariableSpeed\",'+
		'        \"isVerified\": false,'+
		'        \"ahriReferenceNumber\": \"\",'+
		'        \"heating\": {'+
		'          \"efficiency\": 0,'+
		'          \"efficiencyType\": \"AFUE\",'+
		'          \"capacity\": 0'+
		'        },'+
		'        \"cooling\": {'+
		'          \"efficiency\": 15,'+
		'          \"efficiencyType\": \"SEER\",'+
		'          \"capacity\": 33.4'+
		'        },'+
		'        \"hotWater\": {'+
		'          \"efficiency\": 0,'+
		'          \"efficiencyType\": \"ENERGY_FACTOR\",'+
		'          \"isTankless\": false,'+
		'          \"tankSize\": 0'+
		'        }'+
		'      },'+
		'      \"dominantHotWaterEquipment\": {'+
		'        \"id\": \"LYG5AM9b\",'+
		'        \"name\": \"3.39UEF HPWH - 50 gal\",'+
		'        \"description\": \"Extra tank insulation (R) 0.0. \",'+
		'        \"fuel\": \"ELECTRIC\",'+
		'        \"equipmentType\": \"HOT_WATER_HEATER\",'+
		'        \"motorType\": \"SingleSpeed\",'+
		'        \"isVerified\": false,'+
		'        \"ahriReferenceNumber\": \"\",'+
		'        \"heating\": {'+
		'          \"efficiency\": 0,'+
		'          \"efficiencyType\": \"AFUE\",'+
		'          \"capacity\": 0'+
		'        },'+
		'        \"cooling\": {'+
		'          \"efficiency\": 0,'+
		'          \"efficiencyType\": \"SEER\",'+
		'          \"capacity\": 0'+
		'        },'+
		'        \"hotWater\": {'+
		'          \"efficiency\": 3.39,'+
		'          \"efficiencyType\": \"UEF\",'+
		'          \"isTankless\": false,'+
		'          \"tankSize\": 50'+
		'        }'+
		'      },'+
		'      \"dominantMechanicalVentilationType\": {'+
		'        \"ventilationType\": \"SupplyOnly\",'+
		'        \"operationalHoursPerDay\": 12,'+
		'        \"watts\": 67,'+
		'        \"ventilationRate\": 130,'+
		'        \"recoveryEfficiency\": 0'+
		'      },'+
		'      \"dominantDistributionSystem\": {'+
		'        \"systemType\": \"ForcedAir\",'+
		'        \"fieldTestStatus\": \"Tested\",'+
		'        \"isTested\": true,'+
		'        \"testedDetails\": {'+
		'          \"sqFtServed\": 3009,'+
		'          \"numberOfReturnGrilles\": 3,'+
		'          \"supplyDuctSurfaceArea\": 812.43,'+
		'          \"returnDuctSurfaceArea\": 451.35,'+
		'          \"isLeakageToOutsideTested\": true,'+
		'          \"leakageToOutside\": 11,'+
		'          \"totalLeakage\": 161,'+
		'          \"totalLeakageTestCondition\": \"PostConstruction\",'+
		'          \"ducts\": ['+
		'            {'+
		'              \"location\": \"ConditionedSpace\",'+
		'              \"percentSupplyArea\": 100,'+
		'              \"percentReturnArea\": 100,'+
		'              \"supplyR\": 8,'+
		'              \"returnR\": 8'+
		'            },'+
		'            {'+
		'              \"location\": \"ConditionedSpace\",'+
		'              \"percentSupplyArea\": 0,'+
		'              \"percentReturnArea\": 0,'+
		'              \"supplyR\": 8,'+
		'              \"returnR\": 8'+
		'            },'+
		'            {'+
		'              \"location\": \"ConditionedSpace\",'+
		'              \"percentSupplyArea\": 0,'+
		'              \"percentReturnArea\": 0,'+
		'              \"supplyR\": 8,'+
		'              \"returnR\": 8'+
		'            },'+
		'            {'+
		'              \"location\": \"ConditionedSpace\",'+
		'              \"percentSupplyArea\": 0,'+
		'              \"percentReturnArea\": 0,'+
		'              \"supplyR\": 8,'+
		'              \"returnR\": 8'+
		'            },'+
		'            {'+
		'              \"location\": \"ConditionedSpace\",'+
		'              \"percentSupplyArea\": 0,'+
		'              \"percentReturnArea\": 0,'+
		'              \"supplyR\": 8,'+
		'              \"returnR\": 8'+
		'            },'+
		'            {'+
		'              \"location\": \"ConditionedSpace\",'+
		'              \"percentSupplyArea\": 0,'+
		'              \"percentReturnArea\": 0,'+
		'              \"supplyR\": 8,'+
		'              \"returnR\": 8'+
		'            }'+
		'          ]'+
		'        },'+
		'        \"heatingEquipmentIndex\": 0,'+
		'        \"coolingEquipmentIndex\": 1'+
		'      }'+
		'    },'+
		'    \"equipment\": ['+
		'      {'+
		'        \"equipmentType\": \"FURNACE\",'+
		'        \"heating\": {'+
		'          \"efficiencyType\": \"AFUE\",'+
		'          \"percentLoad\": 100,'+
		'          \"efficiency\": 96.3'+
		'        },'+
		'        \"cooling\": {'+
		'          \"efficiencyType\": \"SEER\",'+
		'          \"percentLoad\": 0,'+
		'          \"efficiency\": 0'+
		'        },'+
		'        \"waterHeating\": {'+
		'          \"efficiencyType\": \"ENERGY_FACTOR\",'+
		'          \"percentLoad\": 0,'+
		'          \"efficiency\": 0'+
		'        }'+
		'      },'+
		'      {'+
		'        \"equipmentType\": \"AIR_CONDITIONER\",'+
		'        \"heating\": {'+
		'          \"efficiencyType\": \"AFUE\",'+
		'          \"percentLoad\": 0,'+
		'          \"efficiency\": 0'+
		'        },'+
		'        \"cooling\": {'+
		'          \"efficiencyType\": \"SEER\",'+
		'          \"percentLoad\": 100,'+
		'          \"efficiency\": 15'+
		'        },'+
		'        \"waterHeating\": {'+
		'          \"efficiencyType\": \"ENERGY_FACTOR\",'+
		'          \"percentLoad\": 0,'+
		'          \"efficiency\": 0'+
		'        }'+
		'      },'+
		'      {'+
		'        \"equipmentType\": \"HOT_WATER_HEATER\",'+
		'        \"heating\": {'+
		'          \"efficiencyType\": \"AFUE\",'+
		'          \"percentLoad\": 0,'+
		'          \"efficiency\": 0'+
		'        },'+
		'        \"cooling\": {'+
		'          \"efficiencyType\": \"SEER\",'+
		'          \"percentLoad\": 0,'+
		'          \"efficiency\": 0'+
		'        },'+
		'        \"waterHeating\": {'+
		'          \"efficiencyType\": \"UEF\",'+
		'          \"percentLoad\": 100,'+
		'          \"efficiency\": 3.39'+
		'        }'+
		'      }'+
		'    ],'+
		'    \"mechanicalEquipment\": ['+
		'      {'+
		'        \"name\": \"Heating Equipment\",'+
		'        \"heatingPercentLoad\": 100,'+
		'        \"coolingPercentLoad\": 0,'+
		'        \"hotWaterPercentLoad\": 0,'+
		'        \"location\": \"ConditionedSpace\",'+
		'        \"type\": {'+
		'          \"id\": \"nb2PlqoY\",'+
		'          \"name\": \"58k furnace, 96.3%, 254kWh\",'+
		'          \"description\": \"\",'+
		'          \"fuel\": \"NATURAL_GAS\",'+
		'          \"equipmentType\": \"FURNACE\",'+
		'          \"motorType\": \"VariableSpeed\",'+
		'          \"isVerified\": false,'+
		'          \"ahriReferenceNumber\": \"\",'+
		'          \"usingDefaultElectricAuxiliaryEnergy\": false,'+
		'          \"electricAuxiliaryEnergy\": 254,'+
		'          \"heating\": {'+
		'            \"efficiency\": 96.3,'+
		'            \"efficiencyType\": \"AFUE\",'+
		'            \"capacity\": 58'+
		'          },'+
		'          \"cooling\": {'+
		'            \"efficiency\": 0,'+
		'            \"efficiencyType\": \"SEER\",'+
		'            \"capacity\": 0'+
		'          },'+
		'          \"hotWater\": {'+
		'            \"efficiency\": 0,'+
		'            \"efficiencyType\": \"ENERGY_FACTOR\",'+
		'            \"isTankless\": false,'+
		'            \"tankSize\": 0'+
		'          }'+
		'        }'+
		'      },'+
		'      {'+
		'        \"name\": \"Cooling Equipment\",'+
		'        \"heatingPercentLoad\": 0,'+
		'        \"coolingPercentLoad\": 100,'+
		'        \"hotWaterPercentLoad\": 0,'+
		'        \"location\": \"ConditionedSpace\",'+
		'        \"type\": {'+
		'          \"id\": \"bLDL1lqb\",'+
		'          \"name\": \"33.4k 15seer\",'+
		'          \"description\": \"\",'+
		'          \"fuel\": \"ELECTRIC\",'+
		'          \"equipmentType\": \"AIR_CONDITIONER\",'+
		'          \"motorType\": \"VariableSpeed\",'+
		'          \"isVerified\": false,'+
		'          \"ahriReferenceNumber\": \"\",'+
		'          \"heating\": {'+
		'            \"efficiency\": 0,'+
		'            \"efficiencyType\": \"AFUE\",'+
		'            \"capacity\": 0'+
		'          },'+
		'          \"cooling\": {'+
		'            \"efficiency\": 15,'+
		'            \"efficiencyType\": \"SEER\",'+
		'            \"capacity\": 33.4'+
		'          },'+
		'          \"hotWater\": {'+
		'            \"efficiency\": 0,'+
		'            \"efficiencyType\": \"ENERGY_FACTOR\",'+
		'            \"isTankless\": false,'+
		'            \"tankSize\": 0'+
		'          }'+
		'        }'+
		'      },'+
		'      {'+
		'        \"name\": \"Water Heater\",'+
		'        \"heatingPercentLoad\": 0,'+
		'        \"coolingPercentLoad\": 0,'+
		'        \"hotWaterPercentLoad\": 100,'+
		'        \"location\": \"ConditionedSpace\",'+
		'        \"type\": {'+
		'          \"id\": \"LYG5AM9b\",'+
		'          \"name\": \"3.39UEF HPWH - 50 gal\",'+
		'          \"description\": \"Extra tank insulation (R) 0.0. \",'+
		'          \"fuel\": \"ELECTRIC\",'+
		'          \"equipmentType\": \"HOT_WATER_HEATER\",'+
		'          \"motorType\": \"SingleSpeed\",'+
		'          \"isVerified\": false,'+
		'          \"ahriReferenceNumber\": \"\",'+
		'          \"heating\": {'+
		'            \"efficiency\": 0,'+
		'            \"efficiencyType\": \"AFUE\",'+
		'            \"capacity\": 0'+
		'          },'+
		'          \"cooling\": {'+
		'            \"efficiency\": 0,'+
		'            \"efficiencyType\": \"SEER\",'+
		'            \"capacity\": 0'+
		'          },'+
		'          \"hotWater\": {'+
		'            \"efficiency\": 3.39,'+
		'            \"efficiencyType\": \"UEF\",'+
		'            \"isTankless\": false,'+
		'            \"tankSize\": 50'+
		'          }'+
		'        }'+
		'      }'+
		'    ],'+
		'    \"mechanicalVentilation\": ['+
		'      {'+
		'        \"ventilationType\": \"SupplyOnly\",'+
		'        \"operationalHoursPerDay\": 12,'+
		'        \"watts\": 67,'+
		'        \"ventilationRate\": 130,'+
		'        \"recoveryEfficiency\": 0'+
		'      }'+
		'    ],'+
		'    \"distributionSystems\": ['+
		'      {'+
		'        \"systemType\": \"ForcedAir\",'+
		'        \"fieldTestStatus\": \"Tested\",'+
		'        \"isTested\": true,'+
		'        \"testedDetails\": {'+
		'          \"sqFtServed\": 3009,'+
		'          \"numberOfReturnGrilles\": 3,'+
		'          \"supplyDuctSurfaceArea\": 812.43,'+
		'          \"returnDuctSurfaceArea\": 451.35,'+
		'          \"isLeakageToOutsideTested\": true,'+
		'          \"leakageToOutside\": 11,'+
		'          \"totalLeakage\": 161,'+
		'          \"totalLeakageTestCondition\": \"PostConstruction\",'+
		'          \"ducts\": ['+
		'            {'+
		'              \"location\": \"ConditionedSpace\",'+
		'              \"percentSupplyArea\": 100,'+
		'              \"percentReturnArea\": 100,'+
		'              \"supplyR\": 8,'+
		'              \"returnR\": 8'+
		'            },'+
		'            {'+
		'              \"location\": \"ConditionedSpace\",'+
		'              \"percentSupplyArea\": 0,'+
		'              \"percentReturnArea\": 0,'+
		'              \"supplyR\": 8,'+
		'              \"returnR\": 8'+
		'            },'+
		'            {'+
		'              \"location\": \"ConditionedSpace\",'+
		'              \"percentSupplyArea\": 0,'+
		'              \"percentReturnArea\": 0,'+
		'              \"supplyR\": 8,'+
		'              \"returnR\": 8'+
		'            },'+
		'            {'+
		'              \"location\": \"ConditionedSpace\",'+
		'              \"percentSupplyArea\": 0,'+
		'              \"percentReturnArea\": 0,'+
		'              \"supplyR\": 8,'+
		'              \"returnR\": 8'+
		'            },'+
		'            {'+
		'              \"location\": \"ConditionedSpace\",'+
		'              \"percentSupplyArea\": 0,'+
		'              \"percentReturnArea\": 0,'+
		'              \"supplyR\": 8,'+
		'              \"returnR\": 8'+
		'            },'+
		'            {'+
		'              \"location\": \"ConditionedSpace\",'+
		'              \"percentSupplyArea\": 0,'+
		'              \"percentReturnArea\": 0,'+
		'              \"supplyR\": 8,'+
		'              \"returnR\": 8'+
		'            }'+
		'          ]'+
		'        },'+
		'        \"heatingEquipmentIndex\": 0,'+
		'        \"coolingEquipmentIndex\": 1'+
		'      }'+
		'    ],'+
		'    \"thermostats\": ['+
		'      {'+
		'        \"thermostatType\": \"Smart\",'+
		'        \"makeAndModel\": \"Ecobee3 Lite\",'+
		'        \"serialNumber\": \"\"'+
		'      }'+
		'    ]'+
		'  },'+
		'  \"onsiteGenerations\": {'+
		'    \"summary\": {'+
		'      \"hasSolarGeneration\": false'+
		'    },'+
		'    \"solarGenerationSystems\": []'+
		'  },'+
		'  \"waterSystem\": {'+
		'    \"fixtureEffectiveness\": \"LOW_FLOW\",'+
		'    \"usingEstimatedHotWaterPipeLength\": false,'+
		'    \"hotWaterPipeLength\": 60,'+
		'    \"allHotWaterPipesInsulatedToAtLeastR3\": false'+
		'  },'+
		'  \"details\": {'+
		'    \"bedrooms\": 3,'+
		'    \"residenceType\": \"SingleFamilyHouse\",'+
		'    \"numberOfFloorsOnOrAboveGrade\": 2,'+
		'    \"programmableThermostat\": true,'+
		'    \"buildingType\": \"EkotropeAsModeled\",'+
		'    \"unitsInBuilding\": 1,'+
		'    \"hasElectricVehicleReadySpace\": false'+
		'  }'+
		'}';
		housePlanJSON2Apex r = housePlanJSON2Apex.parse(json);
		System.assert(r != null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		housePlanJSON2Apex.DominantMechanicalVentilationType objDominantMechanicalVentilationType = new housePlanJSON2Apex.DominantMechanicalVentilationType(System.JSON.createParser(json));
		System.assert(objDominantMechanicalVentilationType != null);
		System.assert(objDominantMechanicalVentilationType.ventilationType == null);
		System.assert(objDominantMechanicalVentilationType.operationalHoursPerDay == null);
		System.assert(objDominantMechanicalVentilationType.watts == null);
		System.assert(objDominantMechanicalVentilationType.ventilationRate == null);
		System.assert(objDominantMechanicalVentilationType.recoveryEfficiency == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		housePlanJSON2Apex.Type_Z objType_Z = new housePlanJSON2Apex.Type_Z(System.JSON.createParser(json));
		System.assert(objType_Z != null);
		System.assert(objType_Z.id == null);
		System.assert(objType_Z.name == null);
		System.assert(objType_Z.description == null);
		System.assert(objType_Z.uFactor == null);
		System.assert(objType_Z.hasAssemblyDetails == null);
		System.assert(objType_Z.isVerified == null);
		System.assert(objType_Z.rFactor == null);
		System.assert(objType_Z.distanceInsulationTopToTop == null);
		System.assert(objType_Z.distanceInsulationBottomToTop == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		housePlanJSON2Apex.ClothesDryer objClothesDryer = new housePlanJSON2Apex.ClothesDryer(System.JSON.createParser(json));
		System.assert(objClothesDryer != null);
		System.assert(objClothesDryer.fuel == null);
		System.assert(objClothesDryer.combinedEfficiencyFactor == null);
		System.assert(objClothesDryer.utilizationFactor == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		housePlanJSON2Apex.DominantFoundationWallType objDominantFoundationWallType = new housePlanJSON2Apex.DominantFoundationWallType(System.JSON.createParser(json));
		System.assert(objDominantFoundationWallType != null);
		System.assert(objDominantFoundationWallType.id == null);
		System.assert(objDominantFoundationWallType.name == null);
		System.assert(objDominantFoundationWallType.description == null);
		System.assert(objDominantFoundationWallType.uFactor == null);
		System.assert(objDominantFoundationWallType.hasAssemblyDetails == null);
		System.assert(objDominantFoundationWallType.assemblyDetails == null);
		System.assert(objDominantFoundationWallType.isVerified == null);
		System.assert(objDominantFoundationWallType.rFactor == null);
		System.assert(objDominantFoundationWallType.distanceInsulationTopToTop == null);
		System.assert(objDominantFoundationWallType.distanceInsulationBottomToTop == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		housePlanJSON2Apex.Interior objInterior = new housePlanJSON2Apex.Interior(System.JSON.createParser(json));
		System.assert(objInterior != null);
		System.assert(objInterior.summer == null);
		System.assert(objInterior.winter == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		housePlanJSON2Apex.PercentEfficient objPercentEfficient = new housePlanJSON2Apex.PercentEfficient(System.JSON.createParser(json));
		System.assert(objPercentEfficient != null);
		System.assert(objPercentEfficient.interior == null);
		System.assert(objPercentEfficient.exterior == null);
		System.assert(objPercentEfficient.garage == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		housePlanJSON2Apex.Heating_Z objHeating_Z = new housePlanJSON2Apex.Heating_Z(System.JSON.createParser(json));
		System.assert(objHeating_Z != null);
		System.assert(objHeating_Z.efficiencyType == null);
		System.assert(objHeating_Z.percentLoad == null);
		System.assert(objHeating_Z.efficiency == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		housePlanJSON2Apex.ClothesWasher objClothesWasher = new housePlanJSON2Apex.ClothesWasher(System.JSON.createParser(json));
		System.assert(objClothesWasher != null);
		System.assert(objClothesWasher.labeledEnergyRating == null);
		System.assert(objClothesWasher.electricRate == null);
		System.assert(objClothesWasher.gasRate == null);
		System.assert(objClothesWasher.annualGasCost == null);
		System.assert(objClothesWasher.capacity == null);
		System.assert(objClothesWasher.integratedModifiedEnergyFactor == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		housePlanJSON2Apex.DominantCeilingType objDominantCeilingType = new housePlanJSON2Apex.DominantCeilingType(System.JSON.createParser(json));
		System.assert(objDominantCeilingType != null);
		System.assert(objDominantCeilingType.id == null);
		System.assert(objDominantCeilingType.name == null);
		System.assert(objDominantCeilingType.description == null);
		System.assert(objDominantCeilingType.uFactor == null);
		System.assert(objDominantCeilingType.hasAssemblyDetails == null);
		System.assert(objDominantCeilingType.assemblyDetails == null);
		System.assert(objDominantCeilingType.isVerified == null);
		System.assert(objDominantCeilingType.radiantBarrier == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		housePlanJSON2Apex.DominantWindowType objDominantWindowType = new housePlanJSON2Apex.DominantWindowType(System.JSON.createParser(json));
		System.assert(objDominantWindowType != null);
		System.assert(objDominantWindowType.id == null);
		System.assert(objDominantWindowType.name == null);
		System.assert(objDominantWindowType.description == null);
		System.assert(objDominantWindowType.uFactor == null);
		System.assert(objDominantWindowType.SHGC == null);
		System.assert(objDominantWindowType.isVerified == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		housePlanJSON2Apex.ShadingFactors objShadingFactors = new housePlanJSON2Apex.ShadingFactors(System.JSON.createParser(json));
		System.assert(objShadingFactors != null);
		System.assert(objShadingFactors.interior == null);
		System.assert(objShadingFactors.adjacent == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		housePlanJSON2Apex.Doors objDoors = new housePlanJSON2Apex.Doors(System.JSON.createParser(json));
		System.assert(objDoors != null);
		System.assert(objDoors.name == null);
		System.assert(objDoors.installedWallIndex == null);
		System.assert(objDoors.surfaceArea == null);
		System.assert(objDoors.type_Z == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		housePlanJSON2Apex.Mechanicals objMechanicals = new housePlanJSON2Apex.Mechanicals(System.JSON.createParser(json));
		System.assert(objMechanicals != null);
		System.assert(objMechanicals.summary == null);
		System.assert(objMechanicals.equipment == null);
		System.assert(objMechanicals.mechanicalEquipment == null);
		System.assert(objMechanicals.mechanicalVentilation == null);
		System.assert(objMechanicals.distributionSystems == null);
		System.assert(objMechanicals.thermostats == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		housePlanJSON2Apex.DominantDistributionSystem objDominantDistributionSystem = new housePlanJSON2Apex.DominantDistributionSystem(System.JSON.createParser(json));
		System.assert(objDominantDistributionSystem != null);
		System.assert(objDominantDistributionSystem.systemType == null);
		System.assert(objDominantDistributionSystem.fieldTestStatus == null);
		System.assert(objDominantDistributionSystem.isTested == null);
		System.assert(objDominantDistributionSystem.testedDetails == null);
		System.assert(objDominantDistributionSystem.heatingEquipmentIndex == null);
		System.assert(objDominantDistributionSystem.coolingEquipmentIndex == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		housePlanJSON2Apex.Slabs objSlabs = new housePlanJSON2Apex.Slabs(System.JSON.createParser(json));
		System.assert(objSlabs != null);
		System.assert(objSlabs.name == null);
		System.assert(objSlabs.encloses == null);
		System.assert(objSlabs.surfaceArea == null);
		System.assert(objSlabs.exteriorPerimeter == null);
		System.assert(objSlabs.exposedMasonryArea == null);
		System.assert(objSlabs.grade == null);
		System.assert(objSlabs.type_Z == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		housePlanJSON2Apex.MechanicalEquipment objMechanicalEquipment = new housePlanJSON2Apex.MechanicalEquipment(System.JSON.createParser(json));
		System.assert(objMechanicalEquipment != null);
		System.assert(objMechanicalEquipment.name == null);
		System.assert(objMechanicalEquipment.heatingPercentLoad == null);
		System.assert(objMechanicalEquipment.coolingPercentLoad == null);
		System.assert(objMechanicalEquipment.hotWaterPercentLoad == null);
		System.assert(objMechanicalEquipment.location == null);
		System.assert(objMechanicalEquipment.type_Z == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		housePlanJSON2Apex.Cooling objCooling = new housePlanJSON2Apex.Cooling(System.JSON.createParser(json));
		System.assert(objCooling != null);
		System.assert(objCooling.efficiency == null);
		System.assert(objCooling.efficiencyType == null);
		System.assert(objCooling.capacity == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		housePlanJSON2Apex.DominantSlabType objDominantSlabType = new housePlanJSON2Apex.DominantSlabType(System.JSON.createParser(json));
		System.assert(objDominantSlabType != null);
		System.assert(objDominantSlabType.id == null);
		System.assert(objDominantSlabType.name == null);
		System.assert(objDominantSlabType.description == null);
		System.assert(objDominantSlabType.isVerified == null);
		System.assert(objDominantSlabType.slabCompletelyInsulated == null);
		System.assert(objDominantSlabType.perimeterRValue == null);
		System.assert(objDominantSlabType.underSlabRValue == null);
		System.assert(objDominantSlabType.underslabInsulationWidth == null);
		System.assert(objDominantSlabType.perimeterInsulationDepth == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		housePlanJSON2Apex.Ducts objDucts = new housePlanJSON2Apex.Ducts(System.JSON.createParser(json));
		System.assert(objDucts != null);
		System.assert(objDucts.location == null);
		System.assert(objDucts.percentSupplyArea == null);
		System.assert(objDucts.percentReturnArea == null);
		System.assert(objDucts.supplyR == null);
		System.assert(objDucts.returnR == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		housePlanJSON2Apex.RangeOven objRangeOven = new housePlanJSON2Apex.RangeOven(System.JSON.createParser(json));
		System.assert(objRangeOven != null);
		System.assert(objRangeOven.fuel == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		housePlanJSON2Apex.DominantHeatingEquipmentType objDominantHeatingEquipmentType = new housePlanJSON2Apex.DominantHeatingEquipmentType(System.JSON.createParser(json));
		System.assert(objDominantHeatingEquipmentType != null);
		System.assert(objDominantHeatingEquipmentType.id == null);
		System.assert(objDominantHeatingEquipmentType.name == null);
		System.assert(objDominantHeatingEquipmentType.description == null);
		System.assert(objDominantHeatingEquipmentType.fuel == null);
		System.assert(objDominantHeatingEquipmentType.equipmentType == null);
		System.assert(objDominantHeatingEquipmentType.motorType == null);
		System.assert(objDominantHeatingEquipmentType.isVerified == null);
		System.assert(objDominantHeatingEquipmentType.ahriReferenceNumber == null);
		System.assert(objDominantHeatingEquipmentType.usingDefaultElectricAuxiliaryEnergy == null);
		System.assert(objDominantHeatingEquipmentType.electricAuxiliaryEnergy == null);
		System.assert(objDominantHeatingEquipmentType.heating == null);
		System.assert(objDominantHeatingEquipmentType.cooling == null);
		System.assert(objDominantHeatingEquipmentType.hotWater == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		housePlanJSON2Apex.TestedDetails objTestedDetails = new housePlanJSON2Apex.TestedDetails(System.JSON.createParser(json));
		System.assert(objTestedDetails != null);
		System.assert(objTestedDetails.sqFtServed == null);
		System.assert(objTestedDetails.numberOfReturnGrilles == null);
		System.assert(objTestedDetails.supplyDuctSurfaceArea == null);
		System.assert(objTestedDetails.returnDuctSurfaceArea == null);
		System.assert(objTestedDetails.isLeakageToOutsideTested == null);
		System.assert(objTestedDetails.leakageToOutside == null);
		System.assert(objTestedDetails.totalLeakage == null);
		System.assert(objTestedDetails.totalLeakageTestCondition == null);
		System.assert(objTestedDetails.ducts == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		housePlanJSON2Apex.Details objDetails = new housePlanJSON2Apex.Details(System.JSON.createParser(json));
		System.assert(objDetails != null);
		System.assert(objDetails.bedrooms == null);
		System.assert(objDetails.residenceType == null);
		System.assert(objDetails.numberOfFloorsOnOrAboveGrade == null);
		System.assert(objDetails.programmableThermostat == null);
		System.assert(objDetails.buildingType == null);
		System.assert(objDetails.unitsInBuilding == null);
		System.assert(objDetails.hasElectricVehicleReadySpace == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		housePlanJSON2Apex.AssemblyDetails_Z objAssemblyDetails_Z = new housePlanJSON2Apex.AssemblyDetails_Z(System.JSON.createParser(json));
		System.assert(objAssemblyDetails_Z != null);
		System.assert(objAssemblyDetails_Z.cavityR == null);
		System.assert(objAssemblyDetails_Z.cavityInsulationGrade == null);
		System.assert(objAssemblyDetails_Z.cavityInsulationMaterial == null);
		System.assert(objAssemblyDetails_Z.continuousR == null);
		System.assert(objAssemblyDetails_Z.framingSpacing == null);
		System.assert(objAssemblyDetails_Z.framingDepth == null);
		System.assert(objAssemblyDetails_Z.framingFraction == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		housePlanJSON2Apex.Infiltration objInfiltration = new housePlanJSON2Apex.Infiltration(System.JSON.createParser(json));
		System.assert(objInfiltration != null);
		System.assert(objInfiltration.fieldTestStatus == null);
		System.assert(objInfiltration.cfm50 == null);
		System.assert(objInfiltration.ach50 == null);
		System.assert(objInfiltration.effectiveLeakageArea == null);
		System.assert(objInfiltration.specificLeakageArea == null);
		System.assert(objInfiltration.heatingNaturalACH == null);
		System.assert(objInfiltration.coolingNaturalACH == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		housePlanJSON2Apex.FoundationWalls objFoundationWalls = new housePlanJSON2Apex.FoundationWalls(System.JSON.createParser(json));
		System.assert(objFoundationWalls != null);
		System.assert(objFoundationWalls.name == null);
		System.assert(objFoundationWalls.encloses == null);
		System.assert(objFoundationWalls.betweenInteriorAnd == null);
		System.assert(objFoundationWalls.heightAboveGrade == null);
		System.assert(objFoundationWalls.depthBelowGrade == null);
		System.assert(objFoundationWalls.perimeter == null);
		System.assert(objFoundationWalls.type_Z == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		housePlanJSON2Apex.Walls objWalls = new housePlanJSON2Apex.Walls(System.JSON.createParser(json));
		System.assert(objWalls != null);
		System.assert(objWalls.name == null);
		System.assert(objWalls.surfaceColor == null);
		System.assert(objWalls.betweenInteriorAnd == null);
		System.assert(objWalls.surfaceArea == null);
		System.assert(objWalls.type_Z == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		housePlanJSON2Apex.FramedFloors objFramedFloors = new housePlanJSON2Apex.FramedFloors(System.JSON.createParser(json));
		System.assert(objFramedFloors != null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		housePlanJSON2Apex.DominantWallType objDominantWallType = new housePlanJSON2Apex.DominantWallType(System.JSON.createParser(json));
		System.assert(objDominantWallType != null);
		System.assert(objDominantWallType.id == null);
		System.assert(objDominantWallType.name == null);
		System.assert(objDominantWallType.description == null);
		System.assert(objDominantWallType.uFactor == null);
		System.assert(objDominantWallType.hasAssemblyDetails == null);
		System.assert(objDominantWallType.assemblyDetails == null);
		System.assert(objDominantWallType.isVerified == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		housePlanJSON2Apex objhousePlanJSON2Apex = new housePlanJSON2Apex(System.JSON.createParser(json));
		System.assert(objhousePlanJSON2Apex != null);
		System.assert(objhousePlanJSON2Apex.id == null);
		System.assert(objhousePlanJSON2Apex.name == null);
		System.assert(objhousePlanJSON2Apex.lighting == null);
		System.assert(objhousePlanJSON2Apex.appliances == null);
		System.assert(objhousePlanJSON2Apex.thermalEnvelope == null);
		System.assert(objhousePlanJSON2Apex.mechanicals == null);
		System.assert(objhousePlanJSON2Apex.onsiteGenerations == null);
		System.assert(objhousePlanJSON2Apex.waterSystem == null);
		System.assert(objhousePlanJSON2Apex.details == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		housePlanJSON2Apex.Windows objWindows = new housePlanJSON2Apex.Windows(System.JSON.createParser(json));
		System.assert(objWindows != null);
		System.assert(objWindows.name == null);
		System.assert(objWindows.orientation == null);
		System.assert(objWindows.installedWallIndex == null);
		System.assert(objWindows.surfaceArea == null);
		System.assert(objWindows.type_Z == null);
		System.assert(objWindows.overhangDepth == null);
		System.assert(objWindows.distanceOverhangToTop == null);
		System.assert(objWindows.distanceOverhangToBottom == null);
		System.assert(objWindows.shadingFactors == null);
		System.assert(objWindows.installedFoundationWallIndex == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		housePlanJSON2Apex.DominantCoolingEquipmentType objDominantCoolingEquipmentType = new housePlanJSON2Apex.DominantCoolingEquipmentType(System.JSON.createParser(json));
		System.assert(objDominantCoolingEquipmentType != null);
		System.assert(objDominantCoolingEquipmentType.id == null);
		System.assert(objDominantCoolingEquipmentType.name == null);
		System.assert(objDominantCoolingEquipmentType.description == null);
		System.assert(objDominantCoolingEquipmentType.fuel == null);
		System.assert(objDominantCoolingEquipmentType.equipmentType == null);
		System.assert(objDominantCoolingEquipmentType.motorType == null);
		System.assert(objDominantCoolingEquipmentType.isVerified == null);
		System.assert(objDominantCoolingEquipmentType.ahriReferenceNumber == null);
		System.assert(objDominantCoolingEquipmentType.heating == null);
		System.assert(objDominantCoolingEquipmentType.cooling == null);
		System.assert(objDominantCoolingEquipmentType.hotWater == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		housePlanJSON2Apex.Summary_Z objSummary_Z = new housePlanJSON2Apex.Summary_Z(System.JSON.createParser(json));
		System.assert(objSummary_Z != null);
		System.assert(objSummary_Z.ductSystemCount == null);
		System.assert(objSummary_Z.ductLeakageTotal == null);
		System.assert(objSummary_Z.ductLeakageToOutside == null);
		System.assert(objSummary_Z.mechanicalVentilationRate == null);
		System.assert(objSummary_Z.dominantHeatingEquipmentType == null);
		System.assert(objSummary_Z.dominantCoolingEquipmentType == null);
		System.assert(objSummary_Z.dominantHotWaterEquipment == null);
		System.assert(objSummary_Z.dominantMechanicalVentilationType == null);
		System.assert(objSummary_Z.dominantDistributionSystem == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		housePlanJSON2Apex.Summary_Y objSummary_Y = new housePlanJSON2Apex.Summary_Y(System.JSON.createParser(json));
		System.assert(objSummary_Y != null);
		System.assert(objSummary_Y.hasSolarGeneration == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		housePlanJSON2Apex.DominantHotWaterEquipment objDominantHotWaterEquipment = new housePlanJSON2Apex.DominantHotWaterEquipment(System.JSON.createParser(json));
		System.assert(objDominantHotWaterEquipment != null);
		System.assert(objDominantHotWaterEquipment.id == null);
		System.assert(objDominantHotWaterEquipment.name == null);
		System.assert(objDominantHotWaterEquipment.description == null);
		System.assert(objDominantHotWaterEquipment.fuel == null);
		System.assert(objDominantHotWaterEquipment.equipmentType == null);
		System.assert(objDominantHotWaterEquipment.motorType == null);
		System.assert(objDominantHotWaterEquipment.isVerified == null);
		System.assert(objDominantHotWaterEquipment.ahriReferenceNumber == null);
		System.assert(objDominantHotWaterEquipment.heating == null);
		System.assert(objDominantHotWaterEquipment.cooling == null);
		System.assert(objDominantHotWaterEquipment.hotWater == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		housePlanJSON2Apex.Cooling_Z objCooling_Z = new housePlanJSON2Apex.Cooling_Z(System.JSON.createParser(json));
		System.assert(objCooling_Z != null);
		System.assert(objCooling_Z.efficiency == null);
		System.assert(objCooling_Z.efficiencyType == null);
		System.assert(objCooling_Z.capacity == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		housePlanJSON2Apex.ThermalEnvelope objThermalEnvelope = new housePlanJSON2Apex.ThermalEnvelope(System.JSON.createParser(json));
		System.assert(objThermalEnvelope != null);
		System.assert(objThermalEnvelope.summary == null);
		System.assert(objThermalEnvelope.infiltration == null);
		System.assert(objThermalEnvelope.foundationType == null);
		System.assert(objThermalEnvelope.slabs == null);
		System.assert(objThermalEnvelope.framedFloors == null);
		System.assert(objThermalEnvelope.foundationWalls == null);
		System.assert(objThermalEnvelope.walls == null);
		//System.assert(objThermalEnvelope.rimJoists == null);
		//System.assert(objThermalEnvelope.ceilings == null);
		System.assert(objThermalEnvelope.windows == null);
		//System.assert(objThermalEnvelope.skylights == null);
		System.assert(objThermalEnvelope.doors == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		housePlanJSON2Apex.DominantRimJoistType objDominantRimJoistType = new housePlanJSON2Apex.DominantRimJoistType(System.JSON.createParser(json));
		System.assert(objDominantRimJoistType != null);
		System.assert(objDominantRimJoistType.id == null);
		System.assert(objDominantRimJoistType.name == null);
		System.assert(objDominantRimJoistType.description == null);
		System.assert(objDominantRimJoistType.isVerified == null);
		System.assert(objDominantRimJoistType.uFactor == null);
		System.assert(objDominantRimJoistType.rFactor == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		housePlanJSON2Apex.Lighting objLighting = new housePlanJSON2Apex.Lighting(System.JSON.createParser(json));
		System.assert(objLighting != null);
		System.assert(objLighting.percentEfficient == null);
		System.assert(objLighting.percentLED == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		housePlanJSON2Apex.Cooling_Y objCooling_Y = new housePlanJSON2Apex.Cooling_Y(System.JSON.createParser(json));
		System.assert(objCooling_Y != null);
		System.assert(objCooling_Y.efficiencyType == null);
		System.assert(objCooling_Y.percentLoad == null);
		System.assert(objCooling_Y.efficiency == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		housePlanJSON2Apex.Adjacent objAdjacent = new housePlanJSON2Apex.Adjacent(System.JSON.createParser(json));
		System.assert(objAdjacent != null);
		System.assert(objAdjacent.summer == null);
		System.assert(objAdjacent.winter == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		housePlanJSON2Apex.Ceilings objCeilings = new housePlanJSON2Apex.Ceilings(System.JSON.createParser(json));
		System.assert(objCeilings != null);
		System.assert(objCeilings.name == null);
		System.assert(objCeilings.surfaceColor == null);
		System.assert(objCeilings.betweenInteriorAnd == null);
		System.assert(objCeilings.surfaceArea == null);
		System.assert(objCeilings.roofDeckArea == null);
		System.assert(objCeilings.clayConcreteRoofTiles == null);
		System.assert(objCeilings.type_Z == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		housePlanJSON2Apex.RimJoists objRimJoists = new housePlanJSON2Apex.RimJoists(System.JSON.createParser(json));
		System.assert(objRimJoists != null);
		System.assert(objRimJoists.name == null);
		System.assert(objRimJoists.betweenInteriorAnd == null);
		System.assert(objRimJoists.surfaceArea == null);
		System.assert(objRimJoists.type_Z == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		housePlanJSON2Apex.OnsiteGenerations objOnsiteGenerations = new housePlanJSON2Apex.OnsiteGenerations(System.JSON.createParser(json));
		System.assert(objOnsiteGenerations != null);
		System.assert(objOnsiteGenerations.summary == null);
		System.assert(objOnsiteGenerations.solarGenerationSystems == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		housePlanJSON2Apex.WaterSystem objWaterSystem = new housePlanJSON2Apex.WaterSystem(System.JSON.createParser(json));
		System.assert(objWaterSystem != null);
		System.assert(objWaterSystem.fixtureEffectiveness == null);
		System.assert(objWaterSystem.usingEstimatedHotWaterPipeLength == null);
		System.assert(objWaterSystem.hotWaterPipeLength == null);
		System.assert(objWaterSystem.allHotWaterPipesInsulatedToAtLeastR3 == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		housePlanJSON2Apex.DominantDoorType objDominantDoorType = new housePlanJSON2Apex.DominantDoorType(System.JSON.createParser(json));
		System.assert(objDominantDoorType != null);
		System.assert(objDominantDoorType.id == null);
		System.assert(objDominantDoorType.name == null);
		System.assert(objDominantDoorType.description == null);
		System.assert(objDominantDoorType.isVerified == null);
		System.assert(objDominantDoorType.uFactor == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		housePlanJSON2Apex.Appliances objAppliances = new housePlanJSON2Apex.Appliances(System.JSON.createParser(json));
		System.assert(objAppliances != null);
		System.assert(objAppliances.dishwasherEfficiencyType == null);
		System.assert(objAppliances.dishwasherEfficiency == null);
		System.assert(objAppliances.dishwasherPlaceSettings == null);
		System.assert(objAppliances.refrigeratorConsumption == null);
		System.assert(objAppliances.clothesDryer == null);
		System.assert(objAppliances.clothesWasher == null);
		System.assert(objAppliances.rangeOven == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		housePlanJSON2Apex.Equipment objEquipment = new housePlanJSON2Apex.Equipment(System.JSON.createParser(json));
		System.assert(objEquipment != null);
		System.assert(objEquipment.equipmentType == null);
		System.assert(objEquipment.heating == null);
		System.assert(objEquipment.cooling == null);
		System.assert(objEquipment.waterHeating == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		housePlanJSON2Apex.Heating objHeating = new housePlanJSON2Apex.Heating(System.JSON.createParser(json));
		System.assert(objHeating != null);
		System.assert(objHeating.efficiency == null);
		System.assert(objHeating.efficiencyType == null);
		System.assert(objHeating.capacity == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		housePlanJSON2Apex.HotWater_Z objHotWater_Z = new housePlanJSON2Apex.HotWater_Z(System.JSON.createParser(json));
		System.assert(objHotWater_Z != null);
		System.assert(objHotWater_Z.efficiency == null);
		System.assert(objHotWater_Z.efficiencyType == null);
		System.assert(objHotWater_Z.isTankless == null);
		System.assert(objHotWater_Z.tankSize == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		housePlanJSON2Apex.HotWater objHotWater = new housePlanJSON2Apex.HotWater(System.JSON.createParser(json));
		System.assert(objHotWater != null);
		System.assert(objHotWater.efficiency == null);
		System.assert(objHotWater.efficiencyType == null);
		System.assert(objHotWater.isTankless == null);
		System.assert(objHotWater.tankSize == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		housePlanJSON2Apex.PercentLED objPercentLED = new housePlanJSON2Apex.PercentLED(System.JSON.createParser(json));
		System.assert(objPercentLED != null);
		System.assert(objPercentLED.interior == null);
		System.assert(objPercentLED.exterior == null);
		System.assert(objPercentLED.garage == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		housePlanJSON2Apex.AssemblyDetails objAssemblyDetails = new housePlanJSON2Apex.AssemblyDetails(System.JSON.createParser(json));
		System.assert(objAssemblyDetails != null);
		System.assert(objAssemblyDetails.cavityR == null);
		System.assert(objAssemblyDetails.cavityInsulationGrade == null);
		System.assert(objAssemblyDetails.cavityInsulationMaterial == null);
		System.assert(objAssemblyDetails.continuousR == null);
		System.assert(objAssemblyDetails.framingSpacing == null);
		System.assert(objAssemblyDetails.framingDepth == null);
		System.assert(objAssemblyDetails.framingFraction == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		housePlanJSON2Apex.Summary objSummary = new housePlanJSON2Apex.Summary(System.JSON.createParser(json));
		System.assert(objSummary != null);
		System.assert(objSummary.conditionedArea == null);
		System.assert(objSummary.conditionedVolume == null);
		System.assert(objSummary.windowArea == null);
		System.assert(objSummary.wallArea == null);
		System.assert(objSummary.floorArea == null);
		System.assert(objSummary.ceilingArea == null);
		System.assert(objSummary.slabArea == null);
		System.assert(objSummary.totalThermalBoundaryArea == null);
		System.assert(objSummary.aboveGradeThermalBoundaryArea == null);
		System.assert(objSummary.dominantWallType == null);
		System.assert(objSummary.dominantFoundationWallType == null);
		System.assert(objSummary.dominantSlabType == null);
		System.assert(objSummary.dominantRimJoistType == null);
		System.assert(objSummary.dominantCeilingType == null);
		System.assert(objSummary.dominantWindowType == null);
		System.assert(objSummary.dominantDoorType == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		housePlanJSON2Apex.Thermostats objThermostats = new housePlanJSON2Apex.Thermostats(System.JSON.createParser(json));
		System.assert(objThermostats != null);
		System.assert(objThermostats.thermostatType == null);
		System.assert(objThermostats.makeAndModel == null);
		System.assert(objThermostats.serialNumber == null);
	}
}