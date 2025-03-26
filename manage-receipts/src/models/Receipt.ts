import { Model, DataTypes } from 'sequelize';
import  sequelize  from '../config/db';
import { User } from './User';
import { Image } from './Image';
import { Category } from './Category';

export class Receipt extends Model {
  public id!: number;
  public userId!: number;
  public merchant!: string;
  public amount!: number;
  public receiptDate!: Date;
  public categoryId!: number;
  public imageId!: number;
  public readonly createdAt!: Date;
  public readonly updatedAt!: Date;
}

Receipt.init(
  {
    id: {
      type: DataTypes.INTEGER,
      autoIncrement: true,
      primaryKey: true,
    },
    userId: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: User,
        key: 'id',
      },
    },
    merchant: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    amount: {
      type: DataTypes.FLOAT,
      allowNull: false,
    },
    receiptDate: {
      type: DataTypes.DATE,
      allowNull: false,
    },
    categoryId: {
      type: DataTypes.INTEGER,
      allowNull: true,
      references: {
        model: Category,
        key: 'id',
      },
    },
    imageId: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: Image,
        key: 'id',
      },
    },
  },
  {
    sequelize,
    tableName: 'receipts',
  }
);

User.hasMany(Receipt, { foreignKey: 'userId' });
Receipt.belongsTo(User, { foreignKey: 'userId' });

Image.hasMany(Receipt, { foreignKey: 'imageId' });
Receipt.belongsTo(Image, { foreignKey: 'imageId' });

Category.hasMany(Receipt, { foreignKey: 'categoryId' });
Receipt.belongsTo(Category, { foreignKey: 'categoryId' });