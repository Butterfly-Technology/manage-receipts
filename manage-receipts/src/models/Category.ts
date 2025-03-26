import { Model, DataTypes } from 'sequelize';
import  sequelize from '../config/db';

export class Category extends Model {
  public id!: number;
  public name!: string;
  public category_id!: number;
}

Category.init(
  {
    id: {
      type: DataTypes.INTEGER,
      autoIncrement: true,
      primaryKey: true,
    },
    category_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    name: {
      type: DataTypes.STRING,
      allowNull: false,
    },
  },
  {
    sequelize,
    tableName: 'categories',
  }
);